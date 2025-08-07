//
//  DiaryListModel.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import Foundation


struct DiaryEntry: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let title: String
    let content: String
    let emotion: Emotion
    let isFavorite: Bool
}

