//
//  TerrariumModel.swift
//  Plantory
//
//  Created by 박정환 on 7/25/25.
//

import Foundation

// MARK: - Terrarium Response

struct TerrariumResult: Codable, Equatable {
    let terrariumId: Int
    var terrariumWateringCount: Int
    var memberWateringCount: Int
}

// MARK: - Watering (POST /terrariums/{id}/water)

struct WateringResult: Codable {
    let nickname: String?
    let terrariumWateringCountAfterEvent: Int
    let memberWateringCountAfterEvent: Int
    let emotionList: [String: Int]?
    let flowerName: String?
    let flowerEmotion: String?
}


// MARK: - Terrarium Monthly Response (UPDATED)
// New response shape:
// {
//   "isSuccess": true,
//   "code": "string",
//   "message": "string",
//   "result": {
//     "nickname": "string",
//     "terrariumList": [
//       { "terrariumId": 0, "bloomAt": "2025-08-21", "flowerName": "string" }
//     ]
//   }
// }

struct TerrariumMonthlyListItemRaw: Codable {
    let terrariumId: Int
    let bloomAt: String      // "yyyy-MM-dd"
    let flowerName: String
}

struct TerrariumMonthlyResultRaw: Codable {
    let nickname: String
    let terrariumList: [TerrariumMonthlyListItemRaw]
}

struct TerrariumMonthlyListItem: Codable {
    let terrariumId: Int
    let bloomAt: Date
    let flowerName: String
}

struct TerrariumMonthlyResult: Codable {
    let nickname: String
    let terrariumList: [TerrariumMonthlyListItem]
}


// MARK: - Terrarium Detail (GET /terrariums/{terrarium_id})

struct TerrariumDetailRaw: Codable {
    let flowerName: String
    let startAt: String
    let bloomAt: String
    let mostEmotion: String
    let usedDiaries: [UsedDiaryRaw]
    let firstStepDate: String
    let secondStepDate: String
    let thirdStepDate: String
}

struct UsedDiaryRaw: Codable {
    let diaryDate: String
    let diaryId: Int
}

struct UsedDiary: Codable {
    let diaryDate: Date
    let diaryId: Int
}

struct TerrariumDetail: Codable {
    let flowerName: String
    let startAt: Date
    let bloomAt: Date
    let mostEmotion: String
    let usedDiaries: [UsedDiary]
    let firstStepDate: Date
    let secondStepDate: Date
    let thirdStepDate: Date
}
