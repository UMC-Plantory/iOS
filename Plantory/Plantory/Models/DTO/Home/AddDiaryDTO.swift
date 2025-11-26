//
//  AddDiaryDTO.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import Foundation

// MARK: - 일기 작성 요청
struct AddDiaryRequest: Codable {
    let diaryDate: String                 // yyyy-MM-dd
    let emotion: String?                  // NORMAL 필수, TEMP 선택
    let content: String?                  // NORMAL 필수, TEMP 선택
    let sleepStartTime: String?           // yyyy-MM-dd'T'HH:mm
    let sleepEndTime: String?             // yyyy-MM-dd'T'HH:mm
    let diaryImgUrl: String?              // S3 accessUrl
    let status: String                    // NORMAL | TEMP
    let isImgDeleted: Bool?               // PATCH 시만 사용
}

// MARK: - 단일 일기 조회 및 작성 응답 공통 구조
struct DiaryDetailResponse: Codable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String?
    let title: String?
    let content: String?
    let diaryImgUrl: String?
    let status: String
    let aiComment: String?
}

// 기존 호환성 유지 위한 타입 별칭
typealias AddDiaryResponse = DiaryDetailResponse
typealias TempDiaryResponse = DiaryDetailResponse
typealias TempDiaryResult = DiaryDetailResponse

// MARK: - 존재 여부 공통 응답(result)
struct DiaryExistResult: Decodable {
    
    let isExist: Bool

    // 기존 코드에서 result.exist 로 접근하므로 제공
    var exist: Bool { isExist }
    
    //일기 여부 조회와 함께 해당 다이어리에 대한 id가 뜨도록 해야 함
    //백엔드에 요청 완료
}

