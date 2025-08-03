//
//  EmotionStat.swift
//  Plantory
//
//  Created by 박정환 on 8/3/25.
//

import Foundation

struct EmotionStat: Identifiable {
    let id = UUID()
    let imageName: String
    let count: Int
}

let emotionStats: [EmotionStat] = [
    EmotionStat(imageName: "face_angry", count: 3),
    EmotionStat(imageName: "face_happy", count: 2),
    EmotionStat(imageName: "face_neutral", count: 2),
    EmotionStat(imageName: "face_neutral", count: 2),
    EmotionStat(imageName: "face_neutral", count: 2)
]
