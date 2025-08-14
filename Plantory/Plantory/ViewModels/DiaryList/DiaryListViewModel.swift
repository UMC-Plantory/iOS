//
//  DiaryListViewModel.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import Foundation
import Combine

@MainActor
class DiaryListViewModel: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    @Published var diaries: [DiarySummary] = []
    @Published var isLoading: Bool = false //현재 데이터를 불러오는 중인지 여부
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasNext = false
    @Published var query: String = "" // 검색어(옵션)
    
    private var cursor: String? = nil
    private let diaryService: DiaryServiceProtocol
    
  
    
    //나중에 API연결 할 때 무한스크롤뷰여도 페이징 안 해주면 데이터가 너무 무거워지는 거 예방
    private var currentPage = 0
    private let pageSize = 10
    
    /// status 값 정의(서버 문자열을 안전하게 사용)
    private enum DiaryStatus: String { case normal = "NORMAL", temp = "TEMP", scrap = "SCRAP", trash = "TRASH" }

    // MARK: - 의존성 주입 및 비동기 처리
    
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
 
    init(
        diaryService: DiaryServiceProtocol = DiaryService(),
        container: DIContainer
    ) {
        self.diaryService = diaryService
        self.container = container
        loadMore()
    }
    
    
    @Published var editedTitle: String = "친구를 만나 좋았던 하루"
    @Published var editedContent: String = """
    오늘은 점심에 유엠이랑 밥을 먹었는데 너무 맛있었다. 
    저녁에는 친구 집들이를 갔다. 선물로 유리 컵과 접시 세트를 사 갔는데 마침 집에 이런한 것들이 필요했다고 해서 너무 다행이었다. 
    친구들과 재밌는 시간을 보내고 집으로 돌아와서 이렇게 일기를 쓰고 있는 지금이 참 좋은 것 같다.
    """
    
    //MARK: -함수
    //일기 리스트에서 페이지 계속 불러오는 함수
    func loadMore() {
        guard !isLoading else { return }
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newEntries = (1...self.pageSize).map { offset -> DiaryEntry in
                let day = self.currentPage * self.pageSize + offset
                return DiaryEntry(
                    id: day,
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: day)) ?? Date(),
                    title: "친구를 만나 좋았던 하루",
                    content: "오늘은 점심에 유엠이랑 밥을 먹었는데 너무...",
                    emotion: [.HAPPY, .SAD, .ANGRY].randomElement()!,
                    isFavorite: Bool.random()
                )
            }
            self.entries.append(contentsOf: newEntries)
            self.currentPage += 1
            self.isLoading = false
        }
    }
    
    //MARK: -API
    
    ///일기 스크랩 On/OFF(DiaryCheckView에서)
    public func scrapOn(diaryId: Int) {
        guard let i = diaries.firstIndex(where: { $0.diaryId == diaryId }) else { return }
        let backup = diaries
        var m = diaries[i]
        m.status = DiaryStatus.scrap.rawValue   // 로컬 즉시 반영
        diaries[i] = m

        diaryService.scrapOn(id: diaryId)
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

        diaryService.scrapOff(id: diaryId)
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
    
    //일기 휴지통 이동
    
}
