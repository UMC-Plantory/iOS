//
//  Emotion.swift
//  Plantory
//
//  Created by 박병선 on 8/2/25.
//
import Foundation
import SwiftUICore

enum Emotion: String, CaseIterable, Codable {
    case all     = "ALL" // 서버엔 없지만 UI 전용으로 보관
    case ANGRY   = "ANGRY"
    case HAPPY   = "HAPPY"
    case SAD     = "SAD"
    case SOSO    = "SOSO"
    case AMAZING = "AMAZING"
    
    var displayName: String {
        switch self {
        case .all: return "전체"
        case .ANGRY: return "화남"
        case .HAPPY: return "기쁨"
        case .SAD: return "슬픔"
        case .SOSO: return "그저 그럼"
        case .AMAZING: return "놀람"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color("gray01")
        case .ANGRY: return Color(hex: "#D94531")
        case .HAPPY: return Color(hex: "#FFDC75")
        case .SAD: return Color(hex: "#8DB6E1")
        case .SOSO: return Color(hex: "#D0D0D0")
        case .AMAZING: return Color(hex: "#DDFFA1")
        }
    }
    
    var imageName: String {
           switch self {
           case .all:     return "emotion_happy"//all은 서버에 없어서 기본값으로 설정
           case .HAPPY:   return "emotion_happy"
           case .SAD:     return "emotion_sad"
           case .ANGRY:   return "emotion_angry"
           case .SOSO:    return "emotion_soso"
           case .AMAZING: return "emotion_surprised"
           }
       }

}
