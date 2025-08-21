//
//  CheckViewModel.swift
//  Plantory
//
//  Created by 박병선 on 8/15/25.
//

import SwiftUI
import Combine

@MainActor
final class DiaryCheckViewModel: ObservableObject {
    private enum DiaryStatus: String { case normal = "NORMAL", temp = "TEMP", scrap = "SCRAP", trash = "TRASH" }
    
    @Published var summary: DiarySummary?
    
    @Published var toast: CustomToast? = nil
    
    @Published var isLoading = false
    @Published var isSaving: Bool = false
    @Published var isEditing: Bool = false
    
    @Published var errorMessage: String?
    
    private let diaryId: Int
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(diaryId: Int, container: DIContainer) {
        self.diaryId = diaryId
        self.container = container
    }
    
    @Published var editedContent: String = ""
    
    @Published var selectedImage: UIImage?
    @Published var didDeleteProfileImage: Bool = false
    
    // MARK: - 함수
    
    func didTapEditing() async {
        self.isLoading = true
        
        // 1) 프로필 이미지 삭제
        if didDeleteProfileImage == true {
            try? await diaryEdit(profileImgUrl: nil)
            return
        }

        // 2) 새로운 이미지 선택된 경우
        if selectedImage != nil {
            try? await generatePresignedURL()
        }
        
        // 3) 선택된 이미지도 없고 삭제도 아닌 경우
        else {
            try? await diaryEdit(profileImgUrl: nil)
        }
    }
    
    
    // MARK: - API
    
    //일기 불러오는 API
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        container.useCaseService.diaryService.fetchDiary(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.toast = CustomToast(
                        title: "상세 로딩 실패",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("상세 로딩 실패: \(error.errorDescription ?? "알 수 없는 에러")")
                }
            } receiveValue: { [weak self] summary in
                self?.summary = summary
                self?.editedContent = summary.content
            }
            .store(in: &cancellables)
    }
    
    ///일기 스크랩 On/OFF(DiaryCheckView에서)
    public func scrapOn() {
        guard !isLoading else { return }
        isLoading = true

        container.useCaseService.diaryService.scrapOn(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "스크랩 실패",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("스크랩 실패: \(error.errorDescription ?? "알 수 없는 에러")")
                }
            } receiveValue: { [weak self] _ in
                _Concurrency.Task {
                    await self?.load()
                }
            }
            .store(in: &cancellables)
    }

    public func scrapOff() {
        guard !isLoading else { return }
        isLoading = true

        container.useCaseService.diaryService.scrapOff(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "스크랩 취소 실패",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("스크랩 취소 실패: \(error.errorDescription ?? "알 수 없는 에러")")
                }
            } receiveValue: { [weak self] _ in
                _Concurrency.Task {
                    await self?.load()
                }
            }
            .store(in: &cancellables)
    }
   
    public func toggleScrap() { //On/Off 토글
        if summary?.status == "SCRAP" {
            scrapOff()
        } else {
            scrapOn()
        }
    }

    //일기 삭제(휴지통 이동)
    func moveToTrash(onSuccess: (() -> Void)? = nil) {
        guard let diaryId = summary?.diaryId else { return }
        
        isLoading = true
        container.useCaseService.diaryService.moveToTrash(ids: [diaryId])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
               guard let self else { return }
               self.isLoading = false
               if case .failure(let e) = completion {
                   self.errorMessage = "휴지통 이동 실패: \(e)"
                   print("휴지통 이동 실패:", e)
               }
            } receiveValue: { _ in
               print("휴지통 이동 성공")
               onSuccess?()   // 필요하면 여기서 화면 닫기/토스트 등 처리
            }
            .store(in: &cancellables)
   }
    
    //일기 보관
    //임시보관/복원 토글
    func toggleTempStatus(onSuccess: (() -> Void)? = nil) {
        guard let diaryId = summary?.diaryId else { return }

        isLoading = true
        print(diaryId)
        container.useCaseService.diaryService.updateTempStatus(ids: [diaryId])
           .receive(on: DispatchQueue.main)
           .sink { [weak self] completion in
               guard let self else { return }
               self.isLoading = false
               if case .failure(let e) = completion {
                   self.errorMessage = "임시보관 실패: \(e)"
                   print(" 임시보관 토글 실패:", e)
               }
           } receiveValue: { _ in
               print("임시보관 토글 성공")
               onSuccess?()
           }
           .store(in: &cancellables)
    }
    
    /// Presigned URL을 받아오는 API 호출
    func generatePresignedURL() async throws {
        let request = PresignedRequest(
            type: .diary,
            fileName: "diary.jpg"
        )
        
        container.useCaseService.imageService.generatePresignedURL(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "이미지 업로드 에러",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("로그인 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                // url을 성공적으로 받아오면 사진 업로드 API 요청
                _Concurrency.Task {
                    try await self?.putImage(urls: response)
                }
            })
            .store(in: &cancellables)
    }
    
    private func putImage(urls: PresignedResponse) async throws {
        guard let selectedImage = selectedImage else { return }

        if let data = selectedImage.jpegData(compressionQuality: 0.8) {
            container.useCaseService.imageService.putImage(presignedURL: urls.presignedUrl, data: data)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.toast = CustomToast(
                            title: "이미지 업로드 에러",
                            message: "\(error.errorDescription ?? "알 수 없는 에러")"
                        )
                        print("로그인 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                        self?.isLoading = false
                    }
                }, receiveValue: { [weak self] response in
                    // 이미지를 성공적으로 업로드한다면, 회원가입 완료 API 호출
                    _Concurrency.Task {
                        try await self?.diaryEdit(profileImgUrl: urls.accessUrl)
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    //일기 수정
    func diaryEdit(profileImgUrl: String?) async throws {
        guard let summary = summary else { return }
        
        // 저장 로직
        let request = DiaryEditRequest(
            emotion: summary.emotion.rawValue,
            content: editedContent,
            sleepStartTime: nil,
            sleepEndTime: nil,
            diaryImgUrl: profileImgUrl,
            status: summary.status,
            isImgDeleted: didDeleteProfileImage
        )
        
        container.useCaseService.diaryService.editDiary(id: diaryId, data: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "수정 실패",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("수정 실패: \(error.errorDescription ?? "알 수 없는 에러")")
                }
            } receiveValue: { [weak self] updated in
                _Concurrency.Task {
                    await self?.load()
                }
            }
            .store(in: &cancellables)
    }

}
