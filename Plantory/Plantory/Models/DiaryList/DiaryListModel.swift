//
//  DiaryListModel.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import Foundation

//DiaryListView에서 보여줄 일기 데이터 
struct DiaryEntry: Identifiable, Equatable {
    let id :Int
    let date: Date
    let title: String
    let content: String
    let emotion: Emotion
    //let isFavorite: Bool
    var isScrapped: Bool = false
}

// 서버에서 받아온 DiarySummary -> DiaryEntry 로 매핑
extension DiaryEntry {
    init(summary: DiarySummary) {
        self.id = summary.diaryId
        self.date = DateFormatter.yyyyMMdd.date(from: summary.diaryDate) ?? Date()
        self.title = summary.title
        self.content = summary.content
        self.emotion = Emotion(rawValue: summary.emotion) ?? .HAPPY   
        self.isScrapped = (summary.status == "SCRAP")
    }
}

