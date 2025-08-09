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
    let isFavorite: Bool
    var isScrapped: Bool = false
}

