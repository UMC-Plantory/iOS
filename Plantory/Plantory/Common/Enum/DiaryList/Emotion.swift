//
//  Emotion.swift
//  Plantory
//
//  Created by 박병선 on 8/2/25.
//
import Foundation
import SwiftUICore
/*
 enum DiaryEmotion: String, Codable {
     case SAD, ANGRY, HAPPY, SOSO, AMAZING
 }
 */
enum Emotion: String,CaseIterable,Codable {
    case all = "전체" //api요청은 안 보냄..?? 
    case ANGRY = "화남"
    case HAPPY = "기쁨"
    case SAD = "슬픔"
    case SOSO = "그저 그럼"
    case AMAZING = "놀람"
    
    var color: Color {
        switch self {
        case .all: return Color("gray01") //전체의 경우는 감정 책갈피가 없어서 일단 아무 색이나 끼워넣음
        case .ANGRY: return Color(hex: "#D94531")
        case .HAPPY: return Color(hex: "#FFDC75")
        case .SAD: return Color(hex: "#8DB6E1")
        case .SOSO : return Color(hex: "D0D0D0")
        case .AMAZING : return Color(hex: "DDFFA1")
        }
    }
}

