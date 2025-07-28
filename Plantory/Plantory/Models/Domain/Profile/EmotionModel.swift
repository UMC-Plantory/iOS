//
//  EmotionModel.swift
//  Plantory
//
//  Created by 이효주 on 7/9/25.
//

import Foundation

public struct WeeklyEmotionResponse: Decodable {
    /// 통계 기간 시작일 (YYYY-MM-DD)
    public let startDate: Date
    /// 통계 기간 종료일 (YYYY-MM-DD)
    public let endDate: Date
    /// 오늘의 요일 (소문자)
    public let todayWeekday: String
    /// 가장 빈도 높은 감정
    public let mostFrequentEmotion: String
    /// 감정별 빈도 (개수)
    public let emotionFrequency: [String: Int]
    
    private enum CodingKeys: String, CodingKey {
        case startDate, endDate, todayWeekday, mostFrequentEmotion, emotionFrequency
    }
}
