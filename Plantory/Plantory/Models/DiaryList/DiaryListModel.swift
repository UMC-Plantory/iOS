//
//  DiaryListModel.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import Foundation
import SwiftUICore

struct DiaryEntry: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let title: String
    let content: String
    let emotion: Emotion
    let isFavorite: Bool
}

enum Emotion: String,CaseIterable {
    case all = "전체"
    case angry = "화남"
    case happy = "기쁨"
    case sad = "슬픔"
    case soso = "그저 그럼"
    case surprised = "놀람"
    
    var color: Color {
        switch self {
        case .all: return Color("gray01") //전체의 경우는 감정 책갈피가 없어서 일단 아무 색이나 끼워넣음
        case .angry: return Color(hex: "#D94531")
        case .happy: return Color(hex: "#FFDC75")
        case .sad: return Color(hex: "#8DB6E1")
        case .soso : return Color(hex: "D0D0D0")
        case .surprised : return Color(hex: "DDFFA1")
        }
    }
}
