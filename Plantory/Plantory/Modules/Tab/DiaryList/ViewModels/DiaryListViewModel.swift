//
//  DiaryListViewModel.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import Foundation
import Combine
import Moya

@MainActor
class DiaryListViewModel: ObservableObject {
    private var cursor: String? = nil
    private let diaryService : DiaryServiceProtocol
    private let calendar = Calendar.current
    private let currentDate = Date() //현재 날짜 표기
    
    var currentFilter = DiaryFilterRequest(sort: .latest, from: nil, to: nil, emotion: .all, cursor: nil, size: 10)
    //일기 필터 요청을 주입 받음

    @Published var diaries: [DiarySummary] = []
    @Published var isLoading: Bool = false //현재 데이터를 불러오는 중인지 여부
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasNext = false
  
    // MARK: - Filter State
    @Published var sort: SortOrder = .latest     // "latest" | "oldest"
       @Published var from: String? = nil          // "YYYY-MM"
       @Published var to: String? = nil            // "YYYY-MM"
       @Published var emotion: Emotion = .all
       @Published var size: Int = 15
    
    
    @Published var isLoadingDetail = false
    @Published var selectedSummary: DiarySummary?      // 상세 화면 바인딩용
    @Published var detailErrorMessage: String?
    
    
    
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
   
    }
 
    //MARK: -함수

    
    //미래의 달(월)을 식별하는 함수
    func isFutureMonth(year: Int, month: Int) -> Bool {
        guard let compareDate = calendar.date(from: DateComponents(year: year, month: month)) else {
            return false
        }
        return compareDate > currentDate
    }

    
    //필터링 된 함수 불러오는 함수
    public func fetchFilteredDiaries(_ request: DiaryFilterRequest) {
        isLoading = true
        
        container.useCaseService.diaryService.fetchFilteredDiaries(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let failure) = completion {
                    print("필터 조회 오류: \(failure)")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] result in
                // result.diaries: [DiarySummary]
                self?.diaries = result.diaries
                self?.cursor = result.nextCursor
                self?.hasNext = result.hasNext
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    // 상세 조회 (DiaryCheckView로 넘어가기 전/후에 호출)
    public func fetchDiary(diaryId: Int) {
        guard !isLoadingDetail else { return }
        isLoadingDetail = true
        detailErrorMessage = nil
        
        container.useCaseService.diaryService.fetchDiary(id: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingDetail = false
                if case .failure(let err) = completion {
                    self.detailErrorMessage = "일기 조회 실패: \(err)"
                    print(" fetchDiaryDetail error:", err)
                }
            } receiveValue: { [weak self] res in
                guard let self = self else { return }
                
                // DiaryFetchResponse -> DiarySummary 로 매핑
                let mapped = DiarySummary(
                    diaryId:    res.diaryId,
                    diaryDate:  res.diaryDate,
                    title:      res.title,
                    status:     res.status,
                    emotion:    res.emotion,
                    content:    res.content
                )
                self.selectedSummary = mapped
            }
            .store(in: &cancellables)
    }
    
    ///다음 페이지(커서 페이징)
    public func fetchMore() {
           guard hasNext, !isLoading else { return }
           isLoading = true

           let nextReq = DiaryFilterRequest(
            sort: self.sort,
            from: self.from,
            to: self.to,
            emotion: self.emotion,
            cursor: cursor,
            size: self.size
           )

        container.useCaseService.diaryService.fetchFilteredDiaries(nextReq)
               .receive(on: DispatchQueue.main)
               .sink(receiveCompletion: { [weak self] completion in
                   if case .failure(let failure) = completion {
                       print("다음 페이지 오류: \(failure)")
                       self?.isLoading = false
                   }
               }, receiveValue: { [weak self] result in
                   self?.diaries += result.diaries
                   self?.cursor = result.nextCursor
                   self?.hasNext = result.hasNext
                   self?.isLoading = false
               })
               .store(in: &cancellables)
       }
}
