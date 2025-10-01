//
//  HomeDTO.swift
//  Plantory
//
//  Created by 김지우 on 8/12/25.
//

import Foundation

//홈 월간 조회 결과
struct HomeMonthlyResult: Decodable{
    let yearMonth: String
    let wateringProgress: Int
    let continuousRecordCnt: Int
    let diaryDates: [DiaryDate]
}

//캘린더에 표시되는 날짜/감정
struct DiaryDate: Decodable{
    let date: String
    let emotion: String
}

//특정 날짜 클릭 시 조회되는 일기 결과
struct HomeDiaryResult: Decodable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String
    let title: String
}
