//
//  TerrariumModel.swift
//  Plantory
//
//  Created by 박정환 on 7/25/25.
//

import Foundation

struct TerrariumResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TerrariumResultDTO
}

struct TerrariumResultDTO: Codable {
    let terrariumId: Int
    let flowerImgUrl: String
    let terrariumWateringCount: Int
    let memberWateringCount: Int
}

// MARK: - Domain Model

/// 화면에서 사용할 도메인 모델
struct TerrariumResult: Codable, Equatable {
    let terrariumId: Int
    let flowerImgUrl: String
    let terrariumWateringCount: Int
    let memberWateringCount: Int
}

/// DTO → Domain 매핑
extension TerrariumResult {
    init(dto: TerrariumResultDTO) {
        self.terrariumId = dto.terrariumId
        self.flowerImgUrl = dto.flowerImgUrl
        self.terrariumWateringCount = dto.terrariumWateringCount
        self.memberWateringCount = dto.memberWateringCount
    }
}

struct TerrariumMonthlyResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [TerrariumMonthlyDTO]
}

struct TerrariumMonthlyDTO: Codable {
    let terrariumId: Int
    let nickname: String
    let bloomAt: String
    let flowerName: String
}

struct TerrariumMonthly: Codable, Equatable {
    let terrariumId: Int
    let nickname: String
    let bloomAt: String
    let flowerName: String
}

extension TerrariumMonthly {
    init(dto: TerrariumMonthlyDTO) {
        self.terrariumId = dto.terrariumId
        self.nickname = dto.nickname
        self.bloomAt = dto.bloomAt
        self.flowerName = dto.flowerName
    }
}

// MARK: - Terrarium Detail (GET /terrariums/{terrarium_id})

struct TerrariumDetailResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TerrariumDetailDTO
}

struct TerrariumDetailDTO: Codable {
    let startAt: String
    let bloomAt: String
    let mostEmotion: String
    let usedDiaries: [String]
    let firstStepDate: String
    let secondStepDate: String
    let thirdStepDate: String
}

// Domain model
struct TerrariumDetail: Codable, Equatable {
    let startAt: String
    let bloomAt: String
    let mostEmotion: String
    let usedDiaries: [String]
    let firstStepDate: String
    let secondStepDate: String
    let thirdStepDate: String
}

extension TerrariumDetail {
    init(dto: TerrariumDetailDTO) {
        self.startAt = dto.startAt
        self.bloomAt = dto.bloomAt
        self.mostEmotion = dto.mostEmotion
        self.usedDiaries = dto.usedDiaries
        self.firstStepDate = dto.firstStepDate
        self.secondStepDate = dto.secondStepDate
        self.thirdStepDate = dto.thirdStepDate
    }
}
