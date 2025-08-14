//
//  WeeklySleepModel.swift
//  Plantory
//
//  Created by 이효주 on 8/14/25.
//

import Foundation

// MARK: - 공통 프로토콜
/// SleepStats 프로토콜: 평균 수면 시간(시/분) 관련 속성과
/// totalHours, comment 로직을 제공
public protocol SleepStats {
    /// 평균 시간(시) 부분
    var averageHours: Int?    { get }
    /// 평균 시간(분) 부분
    var averageMinutes: Int?  { get }
}

public extension SleepStats {
    /// 평균 수면 시간을 시간 단위(Double)로 변환
    /// 예: 450분 → 7.5시간
    var totalHours: Double {
        Double(averageHours ?? 0) + Double(averageMinutes ?? 0) / 60
    }

    /// totalHours 범위별로 적절한 코멘트 제공
    var comment: String {
        switch totalHours {
        case ..<5:
            return """
            최근 수면 시간이 많이 부족했어요.
            몸도 마음도 쉬어야
            힘을 낼 수 있어요.
            오늘은 조금 더
            휴식을 취해보는 건 어떨까요?
            """
        case 5..<10:
            return """
            이번 주 수면 시간이 적당했어요.
            지금처럼 나에게 맞는 리듬을
            꾸준히 유지해보세요!
            """
        default:
            return """
            충분히 푹 쉬었어요!
            다만 너무 긴 수면은
            오히려 피로를 부를 수 있어요.
            규칙적인 수면 리듬을
            만들어보는 건 어떨까요?
            """
        }
    }
}

// MARK: - Weekly DTO
/// 서버 주간 수면 통계 응답 모델
public struct WeeklySleepResponse: Codable {
    public let startDate: String        // 통계 기간 시작일
    public let endDate: String          // 통계 기간 종료일
    public let averageSleepMinutes: Int // 평균 수면 시간(분)
    public let dailySleepRecords: [DailySleepRecord] // 일별 수면 레코드

    public struct DailySleepRecord: Codable {
        public let day: Int             // 주 내 순번 (1~7)
        public let date: String           // 해당 날짜 (기상일)
        public let sleepStartTime: String // 취침 시각 문자열 ("HH:mm")
        public let sleepEndTime: String     // 기상 시각 문자열 ("HH:mm")
    }
}

// MARK: - DailySleep (뷰 모델)
/// 뷰에서 사용하기 위한 일별 수면 데이터 모델
public struct DailySleep: Identifiable {
    public let id = UUID()              // 고유 식별자
    public let day: Int                 // 주 내 순번
    public let date: Date               // 기상 날짜
    public let weekday: String          // 요일 (한글)
    public let startTime: Date          // 실제 취침 시각 (날짜 포함)
    public let endTime: Date            // 실제 기상 시각 (날짜 포함)

    public init(
        day: Int,
        date: Date,
        weekday: String,
        startTime: Date,
        endTime: Date
    ) {
        self.day = day; self.date = date
        self.weekday = weekday
        self.startTime = startTime; self.endTime = endTime
    }
}

// MARK: - Weekly View Model (WeeklySleepStatsModel)
/// WeeklySleepResponse를 기반으로 DailySleep 배열 및 평균 시/분 분리
public struct WeeklySleepStatsModel: SleepStats {
    public let startDate: Date
    public let endDate: Date
    public let daily: [DailySleep]
    public let averageHours: Int?
    public let averageMinutes: Int?

    // "yyyy-MM-dd" → Date
    private static let ymd: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    // "HH:mm:ss" → Date(시간 성분만)
    private static let hms: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df
    }()

    private static let weekdaysKR = ["일","월","화","수","목","금","토"]

    public init(from response: WeeklySleepResponse, calendar: Calendar = .current) {
        // 기간 파싱
        let s = Self.ymd.date(from: response.startDate)!
        let e = Self.ymd.date(from: response.endDate)!
        self.startDate = s
        self.endDate   = e

        // 평균 분 → 시/분
        let totalMin = response.averageSleepMinutes
        self.averageHours   = totalMin / 60
        self.averageMinutes = totalMin % 60

        // 일별 변환
        self.daily = response.dailySleepRecords.compactMap { rec in
            guard let onlyDate = Self.ymd.date(from: rec.date),
                  let compStart = Self.hms.date(from: rec.sleepStartTime),
                  let compEnd   = Self.hms.date(from: rec.sleepEndTime) else { return nil }

            let dayStart = calendar.startOfDay(for: onlyDate)

            // 기상 시각(초=0으로 버림)
            let endDT = calendar.date(
                bySettingHour: calendar.component(.hour, from: compEnd),
                minute: calendar.component(.minute, from: compEnd),
                second: 0,
                of: dayStart
            )!

            // 취침 시각(초=0으로 버림) + 날짜 교차 처리
            let tentative = calendar.date(
                bySettingHour: calendar.component(.hour, from: compStart),
                minute: calendar.component(.minute, from: compStart),
                second: 0,
                of: dayStart
            )!
            let startDT = tentative <= endDT ? tentative
                                             : calendar.date(byAdding: .day, value: -1, to: tentative)!

            let idx = calendar.component(.weekday, from: onlyDate) - 1
            let kw = Self.weekdaysKR[idx]

            return DailySleep(
                day: rec.day,
                date: onlyDate,
                weekday: kw,
                startTime: startDT,
                endTime: endDT
            )
        }
    }
}
