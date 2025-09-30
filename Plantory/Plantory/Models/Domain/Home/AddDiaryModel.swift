//
//  AddDiaryModel.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import Foundation
import SwiftData

// SwiftData 임시저장 모델 (30일 보관)
@Model
final class DiaryDraft {
    @Attribute(.unique) var diaryDate: String            // yyyy-MM-dd (키)
    var emotion: String?
    var content: String?
    var sleepStartTime: String?
    var sleepEndTime: String?
    var diaryImgUrl: String?
    var createdAt: Date                                  // 보관 시작 시점

    init(diaryDate: String,
         emotion: String? = nil,
         content: String? = nil,
         sleepStartTime: String? = nil,
         sleepEndTime: String? = nil,
         diaryImgUrl: String? = nil,
         createdAt: Date = Date()) {
        self.diaryDate = diaryDate
        self.emotion = emotion
        self.content = content
        self.sleepStartTime = sleepStartTime
        self.sleepEndTime = sleepEndTime
        self.diaryImgUrl = diaryImgUrl
        self.createdAt = createdAt
    }
}
struct DiaryCreateRequest: Encodable {
    let diaryDate: String                    // yyyy-MM-dd
    let emotion: String?                     // NORMAL 필수, TEMP 선택
    let content: String?                     // NORMAL 필수, TEMP 선택
    let sleepStartTime: String?              // yyyy-MM-dd'T'HH:mm
    let sleepEndTime: String?                // yyyy-MM-dd'T'HH:mm
    let diaryImgUrl: String?                 // S3 accessUrl
    let status: String                       // "NORMAL" | "TEMP"
}

// 생성 결과(result)
struct DiaryCreateResult: Decodable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String?
    let title: String?
    let content: String?
    let diaryImgUrl: String?
    let status: String
}

//임시저장 결과 조회
struct TempDiaryExistResult: Decodable {
    let isExist: Bool
}
