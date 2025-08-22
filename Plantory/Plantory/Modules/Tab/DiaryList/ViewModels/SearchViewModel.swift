//
//  SearchViewModel.swift
//  Plantory
//
//  Created by 박병선 on 8/14/25.
//
import Combine
import Foundation
import Moya

@MainActor
final class SearchViewModel: ObservableObject {
    
    // MARK: - Toast
    
    @Published var toast: CustomToast? = nil
    
    @Published var query: String = ""
    @Published var total: Int = 0
    @Published var results: [DiaryFilterSummary] = []
    @Published var currentKeywords: String = ""
    
    @Published var recentKeywords: [String] = []
    
    @Published var isLoading: Bool = false
    @Published var cursor: String? = nil
    @Published var hasNext: Bool = false

    // MARK: - 의존성 주입 및 비동기 처리
    
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()

    //MARK: - initializer
    init(container: DIContainer) {
        self.container = container
    }

    //MARK: - 함수
    
    //일기 검색
    func searchDiary(keyword: String) async {
        guard !keyword.isEmpty else {
            self.toast = CustomToast(
                title: "검색 실패",
                message: "검색어를 한 글자 이상 입력해주세요."
            )
            return
        }
        
        isLoading = true
        
        container.useCaseService.diaryService.searchDiary(DiarySearchRequest(keyword: keyword, cursor: cursor, size: 20))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "검색 실패",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("검색 실패: \(error.errorDescription ?? "알 수 없는 에러")")
                }
            } receiveValue: { [weak self] res in
                if res.diaries.isEmpty {
                    self?.toast = CustomToast(
                        title: "검색 실패",
                        message: "검색한 키워드와 일치하는 일기가 없어요."
                    )
                } else {
                    self?.currentKeywords = keyword
                    self?.results.append(contentsOf: res.diaries)
                    self?.cursor = res.nextCursor
                    self?.hasNext = res.hasNext
                    self?.total = res.total
                    self?.saveRecent(keyword: keyword)
                }
            }
            .store(in: &cancellables)
    }

    ///최근 검색어 유지
    func saveRecent(keyword: String) {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        // 중복 제거 + 최대 10개 유지
        recentKeywords.removeAll(where: { $0 == keyword })
        recentKeywords.insert(keyword, at: 0)
        if recentKeywords.count > 10 { recentKeywords.removeLast() }
    }

    ///모두 지우기
    func clearRecent() { recentKeywords.removeAll() }
}
