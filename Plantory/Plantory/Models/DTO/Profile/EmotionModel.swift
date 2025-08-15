//
//  EmotionModel.swift
//  Plantory
//
//  Created by 이효주 on 7/9/25.
//

import Foundation

public struct EmotionStatsResponse: Codable {
    /// 통계 기간 시작일 (YYYY-MM-DD)
    public let startDate: String
    /// 통계 기간 종료일 (YYYY-MM-DD)
    public let endDate: String
    /// 오늘의 요일
    public let todayWeekday: String
    /// 가장 빈도 높은 감정
    public let mostFrequentEmotion: String
    /// 감정별 빈도 (개수)
    public let emotionFrequency: [String: Int]
}

// 주간, 월간 모두 같은 스키마 이용
public typealias WeeklyEmotionResponse  = EmotionStatsResponse
public typealias MonthlyEmotionResponse = EmotionStatsResponse
