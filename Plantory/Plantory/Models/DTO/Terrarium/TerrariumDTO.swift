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
    let result: [TerrariumMonthly]
}

struct TerrariumMonthly: Codable {
    let terrariumId: Int
    let nickname: String
    let bloomAt: String
    let flowerName: String
}


// MARK: - Terrarium Detail (GET /terrariums/{terrarium_id})

struct TerrariumDetailResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TerrariumDetail
}

struct TerrariumDetail: Codable {
    let startAt: String
    let bloomAt: String
    let mostEmotion: String
    let usedDiaries: [String]
    let firstStepDate: String
    let secondStepDate: String
    let thirdStepDate: String
}
