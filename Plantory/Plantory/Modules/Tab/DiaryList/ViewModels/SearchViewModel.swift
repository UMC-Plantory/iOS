//
//  SearchViewModel.swift
//  Plantory
//
//  Created by 박병선 on 8/14/25.
//
import Combine
import Foundation

final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [DiarySummary] = []
    @Published var recentKeywords: [String] = []
    @Published var isLoading = false
    @Published var cursor: String?
    @Published var hasNext = false

    private var cancellables = Set<AnyCancellable>()
    private let diaryService: DiaryServiceProtocol

    //MARK: -initializer
    init(diaryService: DiaryServiceProtocol) {
        self.diaryService = diaryService
    }

    //MARK: -함수
    //일기 검색
    func searchDiary(keyword: String) {
        guard !keyword.isEmpty else {
                results = []
                return
            }
        isLoading = true
        diaryService.searchDiary(DiarySearchRequest(keyword: keyword, cursor: nil, size: 20))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let e) = completion { print("검색 실패:", e) }
            } receiveValue: { [weak self] res in
                self?.results = res.diaries
                self?.cursor = res.nextCursor
                self?.hasNext = res.hasNext
                self?.saveRecent(keyword: keyword)
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
