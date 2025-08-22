//
//  CheckViewModel.swift
//  Plantory
//
//  Created by 박병선 on 8/15/25.
//
import Foundation
import Combine
import Moya

final class DiaryCheckViewModel: ObservableObject {

    private enum DiaryStatus: String { case normal = "NORMAL", temp = "TEMP", scrap = "SCRAP", trash = "TRASH" }

    // 단일 상세(서버 최신 상태)
    @Published var detail: DiaryFetchResponse? // 단일일기 데이터를 Fetch해 옵니다. 
    @Published var isLoading = false
    @Published var showDeleteSheet = false
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false

    // 편집용 바인딩 값(제목/본문)
    @Published var editedTitle: String = ""
    @Published var editedContent: String = ""

    // DI
    let container: DIContainer
    private let diaryId: Int
    private let diaryService: DiaryServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(diaryId: Int, diaryService: DiaryServiceProtocol, container: DIContainer) {
        self.diaryId = diaryId
        self.diaryService = diaryService
        self.container = container
    }

    // 서버에서 detail을 한 번 받아와서 편집 값 세팅(필요 시 화면 진입 시 호출)
    func loadDetail() {
        isLoading = true
        container.useCaseService.diaryService.fetchDiary(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let e) = completion {
                    self?.errorMessage = "상세 로드 실패: \(e)"
                }
            } receiveValue: { [weak self] res in
                self?.detail = res
                self?.editedTitle = res.title
                self?.editedContent = res.content
            }
            .store(in: &cancellables)
    }

    // MARK: - 스크랩 On
    public func scrapOn(diaryId: Int) {
        guard var d = detail else { return }
        let backup = d
        detail = d.copy(status: "SCRAP")

        container.useCaseService.diaryService.scrapOn(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let e) = completion {
                    print("스크랩 실패: \(e)")
                    self?.detail = backup                 // 롤백
                } else {
                    print("스크랩 성공")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    // MARK: - 스크랩 Off
    public func scrapOff(diaryId: Int) {
        guard var d = detail else { return }
        let backup = d
        let newStatus = (d.status == "SCRAP") ? "NORMAL" : d.status
           detail = d.copy(status: newStatus)
       

        container.useCaseService.diaryService.scrapOff(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let e) = completion {
                    print("스크랩 취소 실패: \(e)")
                    self?.detail = backup
                } else {
                    print("스크랩 취소 성공")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    // MARK: - 스크랩 토글
    public func toggleScrap(diaryId: Int) {
        if detail?.status == DiaryStatus.scrap.rawValue {
            scrapOff(diaryId: diaryId)
        } else {
            scrapOn(diaryId: diaryId)
        }
    }

    // MARK: - 휴지통 이동
    public func moveToTrash(onSuccess: (() -> Void)? = nil) {
        guard var d = detail else { return }
        let id = d.diaryId
        let backup = d

        detail = d.copy(status: "TRASH")
        isLoading = true

        container.useCaseService.diaryService.moveToTrash(ids: [id])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let e) = completion {
                    self.detail = backup
                    self.errorMessage = "휴지통 이동 실패: \(e)"
                    print("휴지통 이동 실패:", e)
                } else {
                    print("휴지통 이동 성공")
                    onSuccess?()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    // MARK: - 임시보관/복원 토글
    public func toggleTempStatus(onSuccess: (() -> Void)? = nil) {
        guard var d = detail else { return }
        let id = d.diaryId

        let backup = d
        let toggled = (d.status == "TEMP") ? "NORMAL" : "TEMP"
            detail = d.copy(status: toggled)
        
        isLoading = true

        container.useCaseService.diaryService.updateTempStatus(ids: [id])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let e) = completion {
                    self.detail = backup
                    self.errorMessage = "임시보관 토글 실패: \(e)"
                    print("임시보관 토글 실패:", e)
                } else {
                    print("임시보관 토글 성공")
                    onSuccess?()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    // MARK: - 수정
    public func diaryEdit(diaryId: Int, request: DiaryEditRequest) {
        isSaving = true
        container.useCaseService.diaryService.editDiary(id: diaryId, data: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSaving = false
                if case .failure(let e) = completion {
                    print("수정 실패:", e)
                }
            } receiveValue: { [weak self] updated in
                // 서버 응답으로 detail 갱신 & 편집 바인딩 갱신
                self?.detail = DiaryFetchResponse(
                    diaryId: updated.diaryId,
                    diaryDate: updated.diaryDate,
                    emotion: updated.emotion,
                    title: updated.title,
                    content: updated.content,
                    diaryImgUrl: updated.diaryImgUrl,
                    status: updated.status
                )
                self?.editedTitle = updated.title
                self?.editedContent = updated.content
                self?.isSaving = false
                print("수정 성공")
            }
            .store(in: &cancellables)
    }
}
