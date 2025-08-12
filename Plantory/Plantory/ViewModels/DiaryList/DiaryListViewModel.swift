//
//  DiaryListViewModel.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import Foundation

@MainActor
class DiaryListViewModel: ObservableObject {
    @Published var entries: [DiaryEntry] = [] //현재까지 불러온 일기 목록을 저장
    @Published var isLoading = false //현재 데이터를 불러오는 중인지 여부
    
    //나중에 API연결 할 때 무한스크롤뷰여도 페이징 안 해주면 데이터가 너무 무거워지는 거 예방
    private var currentPage = 0
    private let pageSize = 10
    
    init() {
        loadMore()
    }
    
    @Published var editedTitle: String = "친구를 만나 좋았던 하루"
    @Published var editedContent: String = """
    오늘은 점심에 유엠이랑 밥을 먹었는데 너무 맛있었다. 
    저녁에는 친구 집들이를 갔다. 선물로 유리 컵과 접시 세트를 사 갔는데 마침 집에 이런한 것들이 필요했다고 해서 너무 다행이었다. 
    친구들과 재밌는 시간을 보내고 집으로 돌아와서 이렇게 일기를 쓰고 있는 지금이 참 좋은 것 같다.
    """
    private let diaryService = DiaryService()//API연결
    
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
    
    
   //스크랩 및 취소(특정 일기(id)에 대해 스크랩 상태가 true면 취소, false면 스크랩 요청을 보내고, 그 결과에 따라 로컬 상태도 바꾸는 함수)
    func toggleScrap(for id: Int) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            if entries[index].isScrapped {//스크랩이 된 상태면
                diaryService.unscrapDiary(id: id) { result in //스크랩 취소 API 호출(unScarpDiary)
                    DispatchQueue.main.async {
                        if case .success = result {
                            self.entries[index].isScrapped = false  //  상태 업데이트
                        }
                    }
                }
            } else {//스크랩이 안 된 상태면
                diaryService.scrapDiary(id: id) { result in//스크랩 API 호출(scrapDiary)
                    DispatchQueue.main.async {
                        if case .success = result {
                            self.entries[index].isScrapped = true   //  상태 업데이트
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
