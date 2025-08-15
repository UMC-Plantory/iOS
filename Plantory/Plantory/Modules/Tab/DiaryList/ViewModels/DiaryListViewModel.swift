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
        loadMoreMock()
    }
 
    //MARK: -함수
    //일기 리스트에서 페이지 계속 불러오는 함수
    func loadMoreMock() {
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
}
