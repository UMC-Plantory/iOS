//
//  TerrariumModel.swift
//  Plantory
//
//  Created by 박정환 on 7/25/25.
//

import Foundation

struct TerrariumResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TerrariumResult
}

struct TerrariumResult: Decodable {
    let terrariumId: Int
    let flowerImgUrl: String
    let terrariumWateringCount: Int
    let memberWateringCount: Int
}

struct WateringResponse: Decodable {
    let memberId: Int
    let wateringCanId: Int
    let emotion: String
    let diaryId: Int
    let terrariumId: Int
    let flower: WateringFlower
    let wateringCansRemaining: Int

    enum CodingKeys: String, CodingKey {
        case memberId = "member_id"
        case wateringCanId = "watering_can_id"
        case emotion
        case diaryId = "diary_id"
        case terrariumId = "terrarium_id"
        case flower
        case wateringCansRemaining = "watering_cans_remaining"
    }
}

struct WateringFlower: Decodable {
    let flowerId: Int
    let name: String
    let flowerImgUrl: String

    enum CodingKeys: String, CodingKey {
        case flowerId = "flower_id"
        case name
        case flowerImgUrl = "flower_img_url"
    }
}
