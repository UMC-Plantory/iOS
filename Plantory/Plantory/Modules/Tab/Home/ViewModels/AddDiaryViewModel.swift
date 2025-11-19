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

enum DiaryFormatters {
    static let day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
}

@Observable
final class AddDiaryViewModel {
    
    // MARK: - Toast
    var toast: CustomToast? = nil
    
    // 모달 상태
    var showLoadNormalPopup: Bool = false       // 저장된 일기 팝업
    var showLoadTempPopup: Bool = false       // 임시 저장된 일기 불러오기
    var showNetworkErrorPopup: Bool = false   // 네트워크 불안정 시 임시 저장 알림
    var showExistingDiaryDateForDatePicker: Date? = nil // DatePicker 중복 감지
    
    // MARK: - 입력 상태 (UI 바인딩)
    var diaryId: Int?
    var diaryDate: String = ""                  // yyyy-MM-dd
    var emotion: String = ""                    // SAD, ANGRY, HAPPY, SOSO, AMAZING
    var content: String = ""                    // NORMAL일 때 필수
    var sleepStartTime: String = ""             // yyyy-MM-dd'T'HH:mm (NORMAL 필수)
    var sleepEndTime: String = ""               // yyyy-MM-dd'T'HH:mm (NORMAL 필수)
    var diaryImage: UIImage? = nil              // 선택
    var status: String = "NORMAL"               // NORMAL / TEMP
    var isImgDeleted: Bool = false              // 이미지 삭제 플래그(교체가 아닌 ‘삭제’ 시 true)
    
    // MARK: - UI 상태
    var isLoading = false
    var isCompleted = false
    var errorMessage: String?
    
    // MARK: - 의존성
    let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    // MARK: - 바인딩 헬퍼
    func setEmotion(_ v: String) { emotion = v }
    func setContent(_ v: String) { content = v }
    func setDiaryDate(_ v: String) { diaryDate = v } // yyyy-MM-dd
    func setSleepTimes(start: String, end: String) { sleepStartTime = start; sleepEndTime = end }
    func setImage(_ img: UIImage?) { diaryImage = img }
    func setStatus(_ v: String) { status = v } // NORMAL or TEMP
    func markImageDeleted(_ deleted: Bool) { isImgDeleted = deleted }
    
    // MARK: - 기존 확정 일기 중복 체크
    func checkExistingFinalizedDiary(for date: Date) {
        let dateString = DiaryFormatters.day.string(from: date)
        self.diaryDate = dateString // 선택한 날짜 즉시 반영
        
        container.useCaseService.addDiaryService
            .fetchNormalDiaryStatus(date: dateString)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                guard let self else { return }
                if case .failure(let e) = c {
                    self.toast = CustomToast(
                        title: "저장 조회 실패",
                        message: e.errorDescription ?? "네트워크 상태를 확인해주세요."
                    )
                }
            }, receiveValue: { [weak self] existsResult in
                guard let self else { return }
                self.showLoadNormalPopup = existsResult.exist
            })
            .store(in: &cancellables)
    }
    
    // MARK: - 임시 저장 로직 (API)
    /// 해당 날짜에 임시저장(TEMP) 일기가 있는지 서버에서 확인
    func checkForTemporaryDiary(for date: Date) {
        let dateString = DiaryFormatters.day.string(from: date)
        self.diaryDate = dateString // 선택한 날짜 즉시 반영
        
        container.useCaseService.addDiaryService
            .fetchTempDiaryResult(date: dateString)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                guard let self else { return }
                if case .failure(let e) = c {
                    self.toast = CustomToast(
                        title: "임시 저장 조회 실패",
                        message: e.errorDescription ?? "네트워크 상태를 확인해주세요."
                    )
                }
            }, receiveValue: { [weak self] existsResult in
                guard let self else { return }
                self.showLoadTempPopup = existsResult.exist
            })
            .store(in: &cancellables)
    }
    
    /// 서버에 저장된 임시 일기 실제 데이터 불러오기
    func loadTemporaryDiary() {
        // 불러올 기준 날짜가 없으면 중단
        guard !diaryDate.isEmpty else {
            self.toast = CustomToast(title: "불러오기 실패", message: "날짜가 선택되지 않았습니다.")
            return
        }
        // diaryId가 없으면 불러올 수 없음 (현재 Router가 id 기반)
        guard let id = diaryId else {
            self.toast = CustomToast(title: "불러오기 실패", message: "임시 일기 ID를 찾을 수 없습니다.")
            self.showLoadTempPopup = false
            return
        }
        
        showLoadTempPopup = false
        
        container.useCaseService.addDiaryService
            .fetchTempDiary(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                guard let self else { return }
                if case .failure(let e) = c {
                    self.toast = CustomToast(
                        title: "임시 저장 불러오기 실패",
                        message: e.errorDescription ?? "네트워크 상태를 확인해주세요."
                    )
                }
            }, receiveValue: { [weak self] temp in
                guard let self else { return }
                self.applyTempDiary(temp)
                self.toast = CustomToast(title: "임시 저장 불러오기", message: "임시 저장된 일기를 불러왔어요.")
            })
            .store(in: &cancellables)
    }
    
    /// TEMP 응답 → ViewModel 상태 반영
    private func applyTempDiary(_ temp: TempDiaryResult) {
        // temp.diaryId 없음 → 해당 라인 제거
        // if let id = temp.diaryId { self.diaryId = id }
        
        // diaryDate 가 String (non-optional) 이므로 바로 대입
        self.diaryDate = temp.diaryDate
        
        // 나머지는 서버가 옵셔널로 줄 수 있다고 가정하고 안전 매핑
        self.emotion        = temp.emotion ?? self.emotion
        self.content        = temp.content ?? ""
        self.sleepStartTime = temp.sleepStartTime ?? ""
        self.sleepEndTime   = temp.sleepEndTime ?? ""
        
        // 이미지 URL → UIImage 변환은 별도 로더 권장
        self.status = "NORMAL"     // 이어서 작성 UX
        self.isImgDeleted = false
    }
    
    
    /// 현재 입력된 내용을 임시 저장합니다. (네트워크 이슈 시 자동 호출될 수 있음)
    func saveTemporaryDiary(status: String = "TEMP") {
        self.status = status
        if status == "TEMP" && self.showNetworkErrorPopup == false {
            self.toast = CustomToast(title: "자동 임시 저장", message: "입력 내용이 자동으로 임시 저장되었습니다.")
        }
        // TODO: 서버 TEMP 저장 API 확정 시 호출부 추가
        print("Mock: 임시 저장 실행. 상태: \(self.status), 날짜: \(self.diaryDate)")
    }
    
    /// 임시 저장 후 나가기
    func tempSaveAndExit() {
        saveTemporaryDiary(status: "TEMP")
    }
    
    // MARK: - 제출
    func submit() {
        guard !isLoading else { return }
        errorMessage = nil
        
        // 필수값 검증
        if status == "NORMAL" {
            let missing: [String] = [
                diaryDate.isEmpty ? "diaryDate" : nil,
                emotion.isEmpty ? "emotion" : nil,
                content.isEmpty ? "content" : nil,
                sleepStartTime.isEmpty ? "sleepStartTime" : nil,
                sleepEndTime.isEmpty ? "sleepEndTime" : nil
            ].compactMap { $0 }
            if !missing.isEmpty {
                errorMessage = "필수값 누락: \(missing.joined(separator: ", "))"
                return
            }
        } else if diaryDate.isEmpty {
            errorMessage = "필수값 누락: diaryDate"
            return
        }
        
        isLoading = true
        
        // 이미지 없으면 바로 작성
        guard let image = diaryImage,
              let data = image.jpegData(compressionQuality: 0.85)
        else {
            createDiary(diaryImgUrl: nil)
            return
        }
        
        // 이미지 있으면 presigned 발급 → 업로드 → accessUrl로 작성
        let fileName = UUID().uuidString + ".jpg"
        let presignedReq = PresignedRequest(type: .diary, fileName: fileName)
        
        container.useCaseService.imageService
            .generatePresignedURL(request: presignedReq)
            .flatMap { [weak self] res -> AnyPublisher<String, APIError> in
                guard let self else { return Empty().eraseToAnyPublisher() }
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
    
    // MARK: - 일기 생성 호출
    private func createDiary(diaryImgUrl: String?) {
        let body = AddDiaryRequest(
            diaryDate: diaryDate,
            emotion: status == "NORMAL" ? emotion : nil,
            content: status == "NORMAL" ? content : nil,
            sleepStartTime: status == "NORMAL" ? sleepStartTime : nil,
            sleepEndTime: status == "NORMAL" ? sleepEndTime : nil,
            diaryImgUrl: diaryImgUrl,
            status: status,
        )
        
        container.useCaseService.addDiaryService
            .createDiary(body)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                if case .failure(let e) = c { self?.handleError(e) }
            }, receiveValue: { [weak self] res in
                // 생성 성공 시 서버가 diaryId 등을 내려줄 수 있음 → 보관
                // 필요 시 self?.diaryId = res.result.diaryId 등으로 매핑
                self?.isLoading = false
                self?.isCompleted = true
            })
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: APIError) {
        isLoading = false
        isCompleted = false
        
        // 네트워크 불안정/API 에러 시 임시 저장 로직 추가
        if case .serverError(let code, _) = error, ["COMMON401", "JWT4001", "JWT4002"].contains(code) {
            // 토큰 오류는 임시 저장 없이 로그인 필요 처리
            errorMessage = error.errorDescription ?? "세션이 만료되었습니다. 다시 로그인해주세요."
        } else if case .moyaError(_) = error {
            // 네트워크 연결 불안정으로 간주
            errorMessage = "네트워크 연결이 불안정합니다. 입력한 내용은 임시 저장됩니다."
            showNetworkErrorPopup = true
            saveTemporaryDiary(status: "TEMP")
        } else {
            errorMessage = error.errorDescription ?? "알 수 없는 오류가 발생했어요."
        }
        
        self.toast = CustomToast(
            title: "일기 작성 오류",
            message: "\(errorMessage ?? "알 수 없는 에러")"
        )
        print("일기 작성 오류: \(errorMessage ?? "unknown")")
    }
    
    // MARK: - 로컬 임시저장 (SwiftData)
    //작성 중이던 일기가 있을 때 자동으로 임시저장
        /// 현재 입력된 내용을 SwiftData(DiaryDraft)에 임시 저장
    func saveLocalDraftIfNeeded(context: ModelContext, selectedDate: Date){
        
        //아직 아무 내용도 저장하지 않은 경우 저장 X
        let hasAnyContent =
        !emotion.isEmpty ||
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !sleepStartTime.isEmpty ||
        !sleepEndTime.isEmpty ||
        diaryImage != nil
        
        guard hasAnyContent else { return }
        
        //diaryDate가 비어있으면 selectedDate로 채우기
        let dateString : String
        if diaryDate.isEmpty{
            dateString = DiaryFormatters.day.string(from: selectedDate)
            diaryDate = dateString
        } else{
            dateString = diaryDate
        }
        
        //해당 날짜에 draft 있는지 조회
        let descriptor = FetchDescriptor<DiaryDraft>(
            predicate: #Predicate { $0.diaryDate == dateString }
            )
        
        do {
            if let existing = try context.fetch(descriptor).first {
                //기존 draft update
                existing.emotion        = emotion.isEmpty ? existing.emotion : emotion
                existing.content        = content.isEmpty ? existing.content : content
                existing.sleepStartTime = sleepStartTime.isEmpty ? existing.sleepStartTime : sleepStartTime
                existing.sleepEndTime   = sleepEndTime.isEmpty ? existing.sleepEndTime : sleepEndTime
                existing.createdAt      = Date()
            } else {
                //새로운 draft 생성
                let draft = DiaryDraft(
                    diaryDate: dateString,
                    emotion: emotion,
                    content: content,
                    sleepStartTime: sleepStartTime,
                    sleepEndTime: sleepEndTime,
                    diaryImgUrl: nil
                )
                context.insert(draft)
            }
            
            try context.save()

            /*
             
            피그마에서는 없는 모달, 혹시 몰라서 일단 넣어만 놓은 확인 메시지
            //일반 자동 저장일 때만 토스트 띄우기(네트워크 에러 X)
            if showNetworkErrorPopup == false {
                toast = CustomToast(
                    title: "임시 저장",
                    message: "작성 중인 일기를 임시 보관함에 저장했어요."
                )
            }
             */

        
        } catch {
            //에러 처리
            //콘솔에 print? 화면에 에러 메시지?
        }
    }
    
    /// 임시 저장 후 나가기 (서버 TEMP + 로컬 SwiftData 둘 다 쓰면 여기서 같이 호출)
    func tempSaveAndExit(context: ModelContext, selectedDate: Date) {
        // 1) 로컬 SwiftData 임시저장
        saveLocalDraftIfNeeded(context: context, selectedDate: selectedDate)

        // 2) 서버 TEMP 저장도 씀 => 유지
        saveTemporaryDiary(status: "TEMP")
    }
}
