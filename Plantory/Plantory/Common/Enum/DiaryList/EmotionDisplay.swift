//
//  EmotionDisplay.swift
//  Plantory
//
//  Created by 주민영 on 8/20/25.
//

import SwiftUI

enum EmotionDisplay: String, CaseIterable, Codable {
    case ANGRY, HAPPY, SAD, SOSO, AMAZING

    var displayName: String {
        switch self {
        case .ANGRY:    return "화난"
        case .HAPPY:    return "기쁜"
        case .SAD:      return "슬픈"
        case .SOSO:     return "그저그런"
        case .AMAZING:  return "놀란"
        }
    }
    
    var imageName: String {
        switch self {
        case .ANGRY:     return "mad_tapped"
        case .HAPPY:     return "happy_tapped"
        case .SAD:       return "sad_tapped"
        case .SOSO:      return "normal_tapped"
        case .AMAZING:   return "surprised_tapped"
        }
    }

    var image: Image {
        Image(imageName)
    }
}
