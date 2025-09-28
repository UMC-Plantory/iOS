//
//  AddDiaryDTO.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

//merge후 Home 폴더 안으로 이동 예정

import Foundation

//일기 작성 요청 구조체
struct AddDiaryRequest: Codable {
    let diaryDate: String
    let emotion: String?
    let content: String?
    let sleepStartTime: String?
    let sleepEndTime: String?
    let diaryImgUrl: String?
    let status: String
}

//일기 작성 응답 구조체
struct AddDiaryResponse: Codable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String?
    let title: String?
    let content: String?
    let diaryImgUrl: String?
    let status: String
}


//일기 임시저장 구조체
struct DiaryExistResult: Decodable {
    let isExist: Bool
}
