//
//  AddDiaryViewModel.swift
//  Plantory
//
//  Created by 주민영 on 8/15/25.
//

import SwiftUI
import Combine
import Moya
import SwiftData
import Network  //  네트워크 모니터링

// MARK: - Status / Emotion

enum AddDiaryStatus: String, Codable {
    case normal = "NORMAL"
    case temp   = "TEMP"
}

enum DiaryEmotion: String, Codable {
    case SAD, ANGRY, HAPPY, SOSO, AMAZING
}

// MARK: - ViewModel

@Observable
final class AddDiaryViewModel {
    
    // MARK: - Toast
    var toast: CustomToast? = nil
    
    // MARK: - 팝업 트리거 상태
    var showAlreadyExistPopup: Bool = false      // 해당 날짜에 NORMAL 일기 이미 있음 → 작성 불가
    var showLoadServerTempPopup: Bool = false    // 서버에 TEMP 보관 있음 → 불러오기 제안
    var showLoadLocalDraftPopup: Bool = false    // 로컬(SwiftData) 임시보관 있음 → 불러오기 제안

    // MARK: - 내부 상태
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 네트워크 상태 (@Observable로 뷰에서 바로 감지)
    var isConnected: Bool = true                  // 현재 네트워크 연결 여부
    private let pathMonitor = NWPathMonitor()
    private let pathQueue  = DispatchQueue(label: "AddDiaryViewModel.Network")

    // MARK: - 입력 상태 (UI 바인딩)
    var diaryDate: String = ""                 // yyyy-MM-dd
    var emotion: String = ""                   // SAD, ANGRY, HAPPY, SOSO, AMAZING
    var content: String = ""                   // NORMAL일 때 필수
    var sleepStartTime: String = ""            // yyyy-MM-dd'T'HH:mm (NORMAL 필수)
    var sleepEndTime: String = ""              // yyyy-MM-dd'T'HH:mm (NORMAL 필수)
    var diaryImage: UIImage? = nil             // 선택
    var status: String = "NORMAL"              // "NORMAL" | "TEMP"

    // MARK: - UI 상태
    var isLoading = false
    var isCompleted = false
    var errorMessage: String?

    // MARK: - 의존성
    let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        startNetworkMonitor()
    }
    
    deinit {
        pathMonitor.cancel()
    }
    
    // MARK: - Network
    private func startNetworkMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
            }
        }
        pathMonitor.start(queue: pathQueue)
    }
    
    // MARK: - 유효성
    /// Step 1(본문 작성)에서 '다음' 버튼 활성화 여부
    var isDiaryContentValid: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 작성 중 무엇이라도 입력이 있었는지 판단 (완전 빈 상태면 저장 X)
    var hasDraftWorthyContent: Bool {
        if !emotion.isEmpty { return true }
        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        if !sleepStartTime.isEmpty || !sleepEndTime.isEmpty { return true }
        if diaryImage != nil { return true }
        return false
    }
    
    // MARK: - 바인딩 헬퍼
    func setEmotion(_ v: String) { emotion = v }
    func setContent(_ v: String) { content = v }
    func setDiaryDate(_ v: String) { diaryDate = v } // yyyy-MM-dd
    func setSleepTimes(start: String, end: String) {
        sleepStartTime = start; sleepEndTime = end
    }
    func setImage(_ img: UIImage?) { diaryImage = img }
    func setStatus(_ v: String) { status = v } // "NORMAL" | "TEMP"
    
    // MARK: - 서버 존재 여부 / TEMP 불러오기
    func checkDiaryExist(for date: String) {
        container.useCaseService.addDiaryService
            .checkDiaryExist(diaryDate: date )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] res in
                      self?.showAlreadyExistPopup = res.isExist
                  })
            .store(in: &cancellables)
    }
    
    func loadServerTempIfAny(for date: String) {
        container.useCaseService.addDiaryService
            .fetchTempDiary(diaryDate: date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                if case .failure = c {
                    self?.showLoadServerTempPopup = false
                }
            }, receiveValue: { [weak self] res in
                guard let self else { return }
                self.applyDraft(
                    date: res.diaryDate,
                    emotion: res.emotion,
                    content: res.content,
                    sleepStart: res.sleepStartTime,
                    sleepEnd: res.sleepEndTime,
                    imgUrl: res.diaryImgUrl
                )
                self.status = "TEMP"
                self.toast = .init(title: "임시저장 불러오기", message: "서버에 보관된 임시 일기를 불러왔어요.")
            })
            .store(in: &cancellables)
    }
    
    // 서버 TEMP 존재 여부만 확인하고, 있을 때만 모달 on
    func probeServerTempExist(for date: String) {
        container.useCaseService.addDiaryService
            .checkTempExist(diaryDate: date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] res in
                      self?.showLoadServerTempPopup = res.isExist
                  })
            .store(in: &cancellables)
    }

    // MARK: - 로컬 임시저장 (SwiftData)
    func saveLocalDraft(context: ModelContext) {
        guard !diaryDate.isEmpty else { return }
        
        // 1. 기존 임시본 조회
        let fetch = FetchDescriptor<DiaryDraft>(predicate: #Predicate { $0.diaryDate == diaryDate })
        
        if let existing = try? context.fetch(fetch).first {
            // 2. 기존 임시본 업데이트
            existing.emotion = emotion
            existing.content = content
            existing.sleepStartTime = sleepStartTime
            existing.sleepEndTime = sleepEndTime
            existing.diaryImgUrl = nil // 이미지 로컬 저장이 스펙 아웃일 경우 nil 처리
            existing.createdAt = Date()
        } else {
            // 3. 새 임시본 삽입
            let draft = DiaryDraft(
                diaryDate: diaryDate,
                emotion: emotion.isEmpty ? nil : emotion,
                content: content.isEmpty ? nil : content,
                sleepStartTime: sleepStartTime.isEmpty ? nil : sleepStartTime,
                sleepEndTime: sleepEndTime.isEmpty ? nil : sleepEndTime,
                diaryImgUrl: nil, // 이미지 로컬 저장이 스펙 아웃일 경우 nil 처리
                createdAt: Date()
            )
            context.insert(draft)
        }
        
        try? context.save()
        toast = .init(title: "임시저장", message: "작성 중인 일기를 임시로 저장했어요.")
    }
    
    // 로컬: 존재만 체크 (적용은 사용자가 '불러오기' 누를 때)
    func hasLocalDraft(context: ModelContext) -> Bool {
        guard !diaryDate.isEmpty else { return false }
        let fetch = FetchDescriptor<DiaryDraft>(predicate: #Predicate { $0.diaryDate == diaryDate })
        return (try? context.fetch(fetch).first) != nil
    }
    
    // 💡 추가: 뷰의 onAppear에서 호출되어 로컬 임시본 존재 여부에 따라 팝업 상태를 설정하는 함수
    func checkLocalDraftExist(context: ModelContext) {
        self.showLoadLocalDraftPopup = hasLocalDraft(context: context)
        
        // 로컬에 임시본이 없어야만 서버 임시본 확인을 진행합니다.
        if !self.showLoadLocalDraftPopup {
            probeServerTempExist(for: self.diaryDate)
        }
    }
    
    func applyLocalDraft(context: ModelContext) {  // 팝업 '불러오기'에서 호출
        guard !diaryDate.isEmpty else { return }
        let fetch = FetchDescriptor<DiaryDraft>(predicate: #Predicate { $0.diaryDate == diaryDate })
        guard let draft = try? context.fetch(fetch).first else { return }
        
        applyDraft(date: draft.diaryDate,
                   emotion: draft.emotion,
                   content: draft.content,
                   sleepStart: draft.sleepStartTime,
                   sleepEnd: draft.sleepEndTime,
                   imgUrl: draft.diaryImgUrl)
                   
        self.showLoadLocalDraftPopup = false // 팝업 닫기
    }
    
    func deleteLocalDraft(context: ModelContext) {
        guard !diaryDate.isEmpty else { return }
        let fetch = FetchDescriptor<DiaryDraft>(predicate: #Predicate { $0.diaryDate == diaryDate })
        if let draft = try? context.fetch(fetch).first {
            context.delete(draft)
            try? context.save()
        }
    }
    
    func purgeOldDrafts(context: ModelContext) {
        let fetch = FetchDescriptor<DiaryDraft>()
        if let all = try? context.fetch(fetch) {
            let limit = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            all.filter { $0.createdAt < limit }.forEach { context.delete($0) }
            try? context.save()
        }
    }
    
    /// 네트워크 팝업 등에서 호출: 상태를 TEMP로 전환 후 로컬 임시저장
    func forceTempAndSave(context: ModelContext) {
        setStatus("TEMP")
        saveLocalDraft(context: context)
        self.toast = CustomToast(
            title: "로컬 임시 저장 완료",
            message: "네트워크 문제로 인해 기기에 임시 저장되었습니다."
        )
    }

    /// 화면 이탈/백그라운드 등에서 호출: 작성중이면 TEMP로 로컬 임시저장
    func autoSaveIfNeeded(context: ModelContext) {
        guard !isCompleted, hasDraftWorthyContent else { return }
        setStatus("TEMP")
        saveLocalDraft(context: context)
    }

    private func applyDraft(
        date: String,
        emotion: String?,
        content: String?,
        sleepStart: String?,
        sleepEnd: String?,
        imgUrl: String?
    ) {
        diaryDate = date
        if let e = emotion { self.emotion = e }
        if let c = content { self.content = c }
        if let s = sleepStart { self.sleepStartTime = s }
        if let e = sleepEnd { self.sleepEndTime = e }
        // 이미지 URL은 필요 시 그대로 사용 (로컬 저장 스펙 아웃)
    }
    
    // MARK: - 제출 (NORMAL/TEMP 공통)
    func submit() {
        guard !isLoading else { return }
        errorMessage = nil

        if status == "NORMAL" {
            let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            let missing: [String] = [
                diaryDate.isEmpty ? "diaryDate" : nil,
                emotion.isEmpty ? "emotion" : nil,
                trimmedContent.isEmpty ? "content" : nil,
                sleepStartTime.isEmpty ? "sleepStartTime" : nil,
                sleepEndTime.isEmpty ? "sleepEndTime" : nil
            ].compactMap { $0 }
            if !missing.isEmpty {
                errorMessage = "필수값 누락: \(missing.joined(separator: ", "))"
                return
            }
        } else {
            if diaryDate.isEmpty {
                errorMessage = "필수값 누락: diaryDate"
                return
            }
        }

        isLoading = true

        // 이미지 없으면 바로 작성
        guard let image = diaryImage,
              let data = image.jpegData(compressionQuality: 0.85)
        else {
            createDiary(diaryImgUrl: nil)
            return
        }

        // 이미지 있을 때: presigned 발급 → PUT 업로드 → accessUrl로 작성
        let fileName = UUID().uuidString + ".jpg"
        let presignedReq = PresignedRequest(type: .diary, fileName: fileName)

        container.useCaseService.imageService
            .generatePresignedURL(request: presignedReq)
            .flatMap { [weak self] res -> AnyPublisher<String, APIError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.container.useCaseService.imageService
                    .putImage(presignedURL: res.presignedUrl, data: data)
                    .map { res.accessUrl }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                if case .failure(let e) = c { self?.handleError(e) }
            }, receiveValue: { [weak self] accessUrl in
                self?.createDiary(diaryImgUrl: accessUrl)
            })
            .store(in: &cancellables)
    }

    private func createDiary(diaryImgUrl: String?) {
        let body = AddDiaryRequest(
            diaryDate: diaryDate,
            emotion: status == "NORMAL" ? emotion : nil,
            content: status == "NORMAL" ? content : nil,
            sleepStartTime: status == "NORMAL" ? sleepStartTime : nil,
            sleepEndTime: status == "NORMAL" ? sleepEndTime : nil,
            diaryImgUrl: diaryImgUrl,
            status: status
        )

        container.useCaseService.addDiaryService
            .createDiary(body)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                if case .failure(let e) = c { self?.handleError(e) }
            }, receiveValue: { [weak self] _ in
                guard let self else { return }
                self.isLoading = false
                self.isCompleted = true
                self.toast = .init(
                    title: status == "TEMP" ? "임시저장 완료" : "저장 완료",
                    message: status == "TEMP" ? "일기를 임시로 저장했어요." : "일기를 저장했어요."
                )
            })
            .store(in: &cancellables)
    }

    private func handleError(_ error: APIError) {
        isLoading = false
        isCompleted = false
        errorMessage = error.errorDescription ?? "알 수 없는 오류가 발생했어요."
        self.toast = CustomToast(
            title: "일기 작성 오류",
            message: "\(error.errorDescription ?? "알 수 없는 에러")"
        )
        print("일기 작성 오류: \(errorMessage!)")
    }
}
