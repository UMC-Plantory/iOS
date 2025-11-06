//
//  AddDiaryDTO.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

// merge후 Home 폴더 안으로 이동 예정

import Foundation

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
}

// MARK: - 존재 여부 공통 응답(result)
struct DiaryExistResult: Decodable {
    let isExist: Bool
}

struct TempDiaryRequest: Decodable{
    let emotion: String?
    let content: String?
    let sleepStartTime: String?
    let sleepEndTime: String?
    let diaryImgUrl: String?
    let status: String
}

// MARK: - 임시 저장 일기 조회 응답
struct TempDiaryResponse: Decodable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String?
    let title: String?
    let content: String?
    let diaryImgUrl: String?
    let status: String            // "TEMP"
}
