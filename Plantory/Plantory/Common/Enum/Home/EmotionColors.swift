//
//  EmotionColors.swift
//  Plantory
//
//  Created by 김지우 on 7/25/25.
//

import Foundation
import SwiftUI

enum EmotionColors : CaseIterable {
    case happy, mad, sad, normal, surprised

    var EmotionColor: Color{
        switch self {
        case .happy:   return Color(.happy)
        case .mad:   return Color(.mad)
        case .sad:   return Color(.sad)
        case .normal:   return Color(.soso)
        case .surprised:   return Color(.surprised)
        }
    }
}



