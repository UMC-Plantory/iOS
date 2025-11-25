//
//  AddDiaryDTO.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//


import Foundation

///NORMAL/TEMP의 응답 구조체를 하나로 합침(전에는 따로 있었음)

// MARK: - 일기 작성 요청
struct AddDiaryRequest: Codable {
    let diaryDate: String                 // yyyy-MM-dd
    let emotion: String?                  // NORMAL 필수, TEMP 선택
    let content: String?                  // NORMAL 필수, TEMP 선택
    let sleepStartTime: String?           // yyyy-MM-dd'T'HH:mm
    let sleepEndTime: String?             // yyyy-MM-dd'T'HH:mm
    let diaryImgUrl: String?              // S3 accessUrl
    let status: String                    // "NORMAL" | "TEMP"
}

// MARK: - 일기 작성 응답
struct AddDiaryResponse: Codable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String?
    let title: String?
    let content: String?
    let diaryImgUrl: String?
    let status: String
    let aiComment: String?
}

// MARK: - 존재 여부 공통 응답(result)
// /diaries/temp-status/exists, /diaries/normal-status/exists 공용
struct DiaryExistResult: Decodable {
    let exist: Bool
}


struct TempDiaryResponse: Decodable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String?
    let title: String?
    let content: String?
    let diaryImgUrl: String?
    let status: String
}

