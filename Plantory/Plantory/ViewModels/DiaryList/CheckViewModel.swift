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
    @Published var diaries: [DiarySummary] = []
    @Published var summary: DiarySummary?
    @Published var isLoading = false
    @Published var showDeleteSheet = false
    @Published var detail: DiaryDetail?
    @Published var errorMessage: String?
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    private let diaryId: Int
    private let diaryService: DiaryServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isSaving: Bool = false
    
    init(diaryId: Int, diaryService: DiaryServiceProtocol, container: DIContainer) {
        self.diaryId = diaryId
        self.diaryService = diaryService
        self.container = container
    }
    
    @Published var editedTitle: String = ""
    @Published var editedContent: String = ""
    
   
    
    //MARK: -API
    
    ///일기 스크랩 On/OFF(DiaryCheckView에서)
    public func scrapOn(diaryId: Int) {
        guard let i = diaries.firstIndex(where: { $0.diaryId == diaryId }) else { return }
        let backup = diaries
        var m = diaries[i]
        m.status = DiaryStatus.scrap.rawValue   // 로컬 즉시 반영
        diaries[i] = m

        container.useCaseService.diaryService.scrapOn(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let e) = completion {
                    print("스크랩 실패: \(e)")
                    self?.diaries = backup // 롤백
                }
            } receiveValue: { _ in /* 성공 시 추가 작업 없음 */ }
            .store(in: &cancellables)
    }

    public func scrapOff(diaryId: Int) {
        guard let i = diaries.firstIndex(where: { $0.diaryId == diaryId }) else { return }
        let backup = diaries
        var m = diaries[i]
        if m.status == DiaryStatus.scrap.rawValue {
            m.status = DiaryStatus.normal.rawValue
        }
        diaries[i] = m

        container.useCaseService.diaryService.scrapOff(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let e) = completion {
                    print("스크랩 취소 실패: \(e)")
                    self?.diaries = backup // 롤백
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
   
    public func toggleScrap(diaryId: Int) {//On/Off 토글
        guard let i = diaries.firstIndex(where: { $0.diaryId == diaryId }) else { return }
        
        if diaries[i].status == "SCRAP" {
            scrapOff(diaryId: diaryId)
        } else {
            scrapOn(diaryId: diaryId)
        }
    }


    //일기 삭제(휴지통 이동)
    func moveToTrash(onSuccess: (() -> Void)? = nil) {
           guard let id = summary?.diaryId else { return }  // 현재 상세가 없으면 리턴
        
           // (옵션) 낙관적 반영: 로컬 상태를 먼저 TRASH로 바꾸기
           let backup = summary
           if var s = summary { s.status = "TRASH"; summary = s }

           isLoading = true
        
        container.useCaseService.diaryService.moveToTrash(ids: [id])
               .receive(on: DispatchQueue.main)
               .sink { [weak self] completion in
                   guard let self else { return }
                   self.isLoading = false
                   if case .failure(let e) = completion {
                       // 실패 시 롤백
                       self.summary = backup
                       self.errorMessage = "휴지통 이동 실패: \(e)"
                       print(" 휴지통 이동 실패:", e)
                   }
               } receiveValue: { [weak self] _ in
                   guard let self else { return }
                   print("휴지통 이동 성공")
                   onSuccess?()   // 필요하면 여기서 화면 닫기/토스트 등 처리
               }
               .store(in: &cancellables)
       }
    
    //일기 보관
    //임시보관/복원 토글
       func toggleTempStatus(onSuccess: (() -> Void)? = nil) {
           guard var s = summary else { return }
           let id = s.diaryId

           // 낙관적 반영: NORMAL ↔ TEMP 로 UI를 먼저 바꿈
           let backup = s
           s.status = (s.status == "TEMP") ? "NORMAL" : "TEMP"
           summary = s

           isLoading = true
           container.useCaseService.diaryService.updateTempStatus(ids: [id])
               .receive(on: DispatchQueue.main)
               .sink { [weak self] completion in
                   guard let self else { return }
                   self.isLoading = false
                   if case .failure(let e) = completion {
                       // 실패 시 롤백
                       self.summary = backup
                       self.errorMessage = "임시보관 토글 실패: \(e)"
                       print(" 임시보관 토글 실패:", e)
                   }
               } receiveValue: { _ in
                   print("임시보관 토글 성공")
                   onSuccess?()
               }
               .store(in: &cancellables)
       }
    
    //일기 수정
    func diaryEdit(diaryId: Int, request: DiaryEditRequest) {
        isSaving = true
        
        container.useCaseService.diaryService.editDiary(id: diaryId, data: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSaving = false
                if case .failure(let e) = completion {
                    print("수정 실패:", e)
                }
            } receiveValue: { [weak self] updated in
                self?.detail = updated // 서버 응답으로 상태 갱신
                self?.isSaving = false
            }
            .store(in: &cancellables)
    }

}
