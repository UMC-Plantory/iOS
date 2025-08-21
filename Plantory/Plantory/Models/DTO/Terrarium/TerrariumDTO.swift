//
//  TerrariumModel.swift
//  Plantory
//
//  Created by 박정환 on 7/25/25.
//

import Foundation

// MARK: - Terrarium Response

struct TerrariumResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TerrariumResult?
}

struct TerrariumResult: Codable, Equatable {
    let terrariumId: Int
    var terrariumWateringCount: Int
    var memberWateringCount: Int
}

// MARK: - Watering (POST /terrariums/{id}/water)

struct WateringResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: WateringResult?
}

struct WateringResult: Codable {
    let nickname: String?
    let terrariumWateringCountAfterEvent: Int
    let memberWateringCountAfterEvent: Int
    let emotionList: [String: Int]?
    let flowerName: String?
    let flowerEmotion: String?
}


// MARK: - Terrarium Monthly Response

struct TerrariumMonthlyResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TerrariumMonthly
}

struct TerrariumMonthlyRaw: Codable {
    let terrariumId: Int
    let nickname: String
    let bloomAt: String      // "yyyy-MM-dd"
    let flowerName: String
}

struct TerrariumMonthly: Codable {
    let terrariumId: Int
    let nickname: String
    let bloomAt: Date
    let flowerName: String
}


// MARK: - Terrarium Detail (GET /terrariums/{terrarium_id})

struct TerrariumDetailResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TerrariumDetail
}

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
