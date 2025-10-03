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
    
    // MARK: - Toast
    
    @Published var toast: CustomToast? = nil
    
    /// status 값 정의(서버 문자열을 안전하게 사용)
    private enum DiaryStatus: String { case normal = "NORMAL", temp = "TEMP", scrap = "SCRAP", trash = "TRASH" }

    @Published var diaries: [DiaryFilterSummary] = []
    
    @Published var isLoading: Bool = false //현재 데이터를 불러오는 중인지 여부
    @Published var hasNext: Bool = true
    @Published var errorMessage: String?
  
    // MARK: - Filter State
    
    @Published var sort: SortOrder = .latest     // "latest" | "oldest"
    @Published var from: String? = {
        let year = Calendar.current.component(.year, from: Date())
        return "\(year)-01"
    }()
    @Published var to: String? = {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: now)
    }()
    @Published var emotion: Set<Emotion> = [.all]
    @Published var cursor: String? = nil
    @Published var size: Int = 10
    
    @Published var isLoadingDetail = false
    @Published var detailErrorMessage: String?

    // MARK: - 의존성 주입 및 비동기 처리
    
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()

    // MARK: - 초기화
 
    init(container: DIContainer) {
        self.container = container
    }
 
    //MARK: - 함수
    
    // 필터링 된 함수 불러오는 함수
    public func fetchFilteredDiaries() async {
        guard hasNext, !isLoading else { return }
        isLoading = true
        
        let emotions: [Emotion] = emotion.contains(.all)
                ? Emotion.sendableCases
                : Emotion.sendableCases.filter { emotion.contains($0) }
        let emotionsArray = Emotion.payload(from: emotions)
        
        let request = DiaryFilterRequest(
            sort: sort,
            from: from,
            to: to,
            emotion: emotionsArray,
            cursor: cursor,
            size: size
        )
        
        container.useCaseService.diaryService.fetchFilteredDiaries(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let failure) = completion {
                    self?.toast = CustomToast(
                        title: "필터 조회 오류",
                        message: "\(failure.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("필터 조회 오류: \(failure)")
                }
            }, receiveValue: { [weak self] result in
                if result.diaries.isEmpty {
                    self?.toast = CustomToast(
                        title: "조회 실패",
                        message: "해당 조건에 맞는 일기가 없어요."
                    )
                } else {
                    self?.diaries.append(contentsOf: result.diaries)
                    self?.cursor = result.nextCursor
                    self?.hasNext = result.hasNext
                }
            })
            .store(in: &cancellables)
    }
}
