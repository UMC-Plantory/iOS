//
//  Emotion.swift
//  Plantory
//
//  Created by 박병선 on 8/2/25.
//
import Foundation
import SwiftUICore

enum Emotion: String,CaseIterable,Codable {
    case all = "전체"
    case ANGRY = "화남"
    case HAPPY = "기쁨"
    case SAD = "슬픔"
    case SOSO = "그저 그럼"
    case AMAZING = "놀람"
    
    var color: Color {
        switch self {
        case .all: return Color("gray01") 
        case .ANGRY: return Color(hex: "#D94531")
        case .HAPPY: return Color(hex: "#FFDC75")
        case .SAD: return Color(hex: "#8DB6E1")
        case .SOSO : return Color(hex: "D0D0D0")
        case .AMAZING : return Color(hex: "DDFFA1")
        }
    }
}

