//
//  DiaryListViewModel.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import Foundation

@MainActor
class DiaryListViewModel: ObservableObject {
    @Published var entries: [DiaryEntry] = []//현재까지 불러온 일기 목록을 저장
    @Published var isLoading = false //현재 데이터를 불러오는 중인지 여부
    
    //나중에 API연결 할 때 무한스크롤뷰여도 페이징 안 해주면 데이터가 너무 무거워지는 거 예방
    private var currentPage = 0
    private let pageSize = 10
    
    init() {
        loadMore()
    }
    
    func loadMore() {
        guard !isLoading else { return }
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newEntries = (1...self.pageSize).map { offset -> DiaryEntry in
                let day = self.currentPage * self.pageSize + offset
                return DiaryEntry(
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: day)) ?? Date(),
                    title: "친구를 만나 좋았던 하루",
                    content: "오늘은 점심에 유엠이랑 밥을 먹었는데 너무...",
                    emotion: [.happy, .sad, .angry].randomElement()!,
                    isFavorite: Bool.random()
                )
            }
            self.entries.append(contentsOf: newEntries)
            self.currentPage += 1
            self.isLoading = false
        }
    }
}
