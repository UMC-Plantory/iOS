//
//  AddDiaryViewModel.swift
//  Plantory
//
//  Created by 주민영 on 8/15/25.
//

import SwiftUI
import Combine
import Moya

@Observable
final class AddDiaryViewModel {

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
        errorMessage = error.errorDescription ?? "알 수 없는 오류가 발생했어요."
        print("일기 작성 오류: \(errorMessage!)")
    }
}
