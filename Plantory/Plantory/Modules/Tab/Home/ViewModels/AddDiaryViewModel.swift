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
    
    //모달 상태
    var showLoadTempPopup: Bool = false      // 임시 저장된 일기 불러오기
    var showNetworkErrorPopup: Bool = false  // 네트워크 불안정 시 임시 저장 알림
    var showExistingDiaryDateForDatePicker: Date? = nil // DatePicker에서 중복 감지 시 사용 (핵심)

    // MARK: - 입력 상태 (UI 바인딩)
    var diaryDate: String = ""                 // yyyy-MM-dd
    var emotion: String = ""                   // SAD, ANGRY, HAPPY, SOSO, AMAZING
    var content: String = ""                   // NORMAL일 때 필수
    var sleepStartTime: String = ""            // yyyy-MM-dd'T'HH:mm (NORMAL 필수)
    var sleepEndTime: String = ""              // yyyy-MM-dd'T'HH:mm (NORMAL 필수)
    var diaryImage: UIImage? = nil             // 선택
    var status: String = "NORMAL"              // NORMAL / TEMP

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
    func setSleepTimes(start: String, end: String) {
        sleepStartTime = start; sleepEndTime = end
    }
    func setImage(_ img: UIImage?) { diaryImage = img }
    func setStatus(_ v: String) { status = v } // NORMAL or TEMP

    // MARK: - 임시 저장 로직 (SwiftData 대체 Mock)

    // 추가: 해당 날짜에 완료된 일기가 있는지 확인 (DatePickerCalendarView에서 사용)
    func checkExistingFinalizedDiary(for date: Date) -> Bool {
        let dateString = DiaryFormatters.day.string(from: date)
        // Mock: 10월 2일은 이미 최종 작성되었다고 가정
        return dateString == "2025-10-02"
    }
    
    // MARK: - 임시 저장 로직 (SwiftData → 실제 API)
    /// 해당 날짜에 임시저장(TEMP) 일기가 있는지 서버에서 확인
    func checkForTemporaryDiary(for date: Date) {
        let dateString = DiaryFormatters.day.string(from: date)
        self.diaryDate = dateString                       // 선택한 날짜는 즉시 반영

        container.useCaseService.addDiaryService.fetchTempDiary(date: diaryDate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                guard let self = self else { return }
                if case .failure(let e) = c {
                    // 조회 실패 시 토스트만 안내(UX 저해 최소화)
                    self.toast = CustomToast(
                        title: "임시 저장 조회 실패",
                        message: e.errorDescription ?? "네트워크 상태를 확인해주세요."
                    )
                }
            }, receiveValue: { [weak self] existsResult in
                guard let self = self else { return }
                // 존재하면 불러오기 모달 표시
                if status.isContiguousUTF8 == true {
                    self.showLoadTempPopup = true
                } else {
                    self.showLoadTempPopup = false
                }
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

        showLoadTempPopup = false

        container.useCaseService.addDiaryService.fetchTempDiary(date: diaryDate)          
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                guard let self = self else { return }
                if case .failure(let e) = c {
                    self.toast = CustomToast(
                        title: "임시 저장 불러오기 실패",
                        message: e.errorDescription ?? "네트워크 상태를 확인해주세요."
                    )
                }
            }, receiveValue: { [weak self] temp in
                guard let self = self else { return }
                self.applyTempDiary(temp)
                self.toast = CustomToast(title: "임시 저장 불러오기", message: "임시 저장된 일기를 불러왔어요.")
            })
            .store(in: &cancellables)
    }

    /// TEMP 응답 → ViewModel 상태 반영
    private func applyTempDiary(_ temp: TempDiaryResponse) {
        // 서버 스키마에 맞춰 안전하게 매핑 (필드명은 실제 Response에 맞게 조정)
        // status는 작성 이어가기 UX를 위해 NORMAL로 전환
        self.emotion        = temp.emotion ?? self.emotion
        self.content        = temp.content ?? ""
        self.sleepStartTime = temp.sleepStartTime ?? ""
        self.sleepEndTime   = temp.sleepEndTime ?? ""
        // 임시: 이미지는 URL 문자열만 반환되는 경우가 많으므로 즉시 UIImage로 변환하지 않음
        // 필요 시 별도 이미지 로더에서 비동기 로딩 권장.
        // self.diaryImage  = ...

        self.status = "NORMAL"
    }

    
    /// 현재 입력된 내용을 임시 저장합니다.
    func saveTemporaryDiary(status: String = "TEMP") {        self.status = status // 상태를 TEMP로 설정
        
        if status == "TEMP" && self.showNetworkErrorPopup == false {
            // 네트워크 오류 팝업과 함께 표시되는 경우는 중복 Toast X
             self.toast = CustomToast(title: "자동 임시 저장", message: "입력 내용이 자동으로 임시 저장되었습니다.")
        }
        
        print("Mock: 임시 저장 실행. 상태: \(self.status), 날짜: \(self.diaryDate)")
    }
    
    /// 임시 저장 후 나가기
    func tempSaveAndExit() {
        saveTemporaryDiary(status: "TEMP") // 강제 임시 저장
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

        // 이미지 있으면 presigned 발급 → 업로드 → accessUrl로 작성
        let fileName = UUID().uuidString + ".jpg"
        let presignedReq = PresignedRequest(type: .diary, fileName: fileName)

        container.useCaseService.imageService
            .generatePresignedURL(request: presignedReq)
            .flatMap { [weak self] res -> AnyPublisher<String, APIError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                // S3 PUT 업로드
                return self.container.useCaseService.imageService
                    .putImage(presignedURL: res.presignedUrl, data: data)
                    .map { res.accessUrl } // 업로드 성공 시 accessUrl 전달
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
            status: status
        )

        container.useCaseService.addDiaryService
            .createDiary(body)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] c in
                if case .failure(let e) = c { self?.handleError(e) }
            }, receiveValue: { [weak self] _ in
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
             // 토큰 오류는 임시 저장 없이 로그인 필요 처리 (기존 로직)
             errorMessage = error.errorDescription ?? "세션이 만료되었습니다. 다시 로그인해주세요."
        } else if case .moyaError(_) = error {
            // Moya 에러는 네트워크 연결 불안정으로 간주
            errorMessage = "네트워크 연결이 불안정합니다. 입력한 내용은 임시 저장됩니다."
            showNetworkErrorPopup = true
            saveTemporaryDiary(status: "TEMP") // 임시 저장 실행
        } else {
            // 그 외 API 에러 처리
            errorMessage = error.errorDescription ?? "알 수 없는 오류가 발생했어요."
        }

        self.toast = CustomToast(
            title: "일기 작성 오류",
            message: "\(errorMessage ?? "알 수 없는 에러")"
        )
        print("일기 작성 오류: \(errorMessage!)")
    }
}
