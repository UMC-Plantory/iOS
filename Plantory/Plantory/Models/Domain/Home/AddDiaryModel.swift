//
//  AddDiaryModel.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import Foundation

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
