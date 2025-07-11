//
//  EmotionModel.swift
//  Plantory
//
//  Created by 이효주 on 7/9/25.
//

import Foundation

public struct WeeklyEmotionResponse: Decodable {
    /// 통계 기간 시작일
    public let startDate: Date
    /// 통계 기간 종료일
    public let endDate: Date
    public let stats: [WeeklyEmotionStat]
    public let comment: String
    
    public struct WeeklyEmotionStat: Decodable, Identifiable {
        public let id: UUID
        public let emotion: String
        public let percentage: Double
    }
}
