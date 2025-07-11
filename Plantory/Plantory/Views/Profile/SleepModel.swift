/// SleepModel.swift
///
/// 이 파일은 수면 통계 관련 도메인 모델과 DTO(응답 데이터)를 정의합니다.
/// 1. SleepStats 프로토콜: 평균 수면 정보와 코멘트 제공
/// 2. WeeklySleepResponse, MonthlySleepResponse: 서버 응답을 디코딩하는 DTO
/// 3. WeeklySleepStatsModel, MonthlySleepStatsModel: 뷰에서 사용할 모델
/// 4. DailySleep: 차트 렌더링용 뷰 모델

import Foundation

// MARK: - 공통 프로토콜
/// 평균 수면 시간(hours, minutes)을 제공하는 프로토콜
public protocol SleepStats {
    var averageHours: Int?    { get }
    var averageMinutes: Int?  { get }
}

public extension SleepStats {
    /// 평균 수면 시간을 시간 단위 소수로 변환
    var totalHours: Double {
        Double(averageHours ?? 0) + Double(averageMinutes ?? 0) / 60
    }

    /// 총 수면 시간에 따라 보여줄 추천 멘트 생성
    var comment: String {
        switch totalHours {
        case ..<5:
            return """
            최근 수면 시간이 많이 부족했어요.
            몸도 마음도 쉬어야 힘을 낼 수 있어요.
            오늘은 조금 더 휴식을 취해보는 건 어떨까요?
            """
        case 5..<10:
            return """
            이번 주 수면 시간이 적당했어요.
            지금처럼 나에게 맞는 리듬을 꾸준히 유지해보세요!
            """
        default:
            return """
            충분히 푹 쉬었어요!
            다만 너무 긴 수면은 오히려 피로를 부를 수 있어요.
            규칙적인 수면 리듬을 만들어보는 건 어떨까요?
            """
        }
    }
}

// MARK: - Weekly DTO
public struct WeeklySleepResponse: Decodable {
    public let startDate: Date
    public let endDate: Date
    public let averageSleepMinutes: Int
    public let dailySleepRecords: [DailySleepRecord]

    public struct DailySleepRecord: Decodable {
        public let day: Int
        public let date: Date
        public let sleepStartTime: String  // "HH:mm"
        public let wakeUpTime: String      // "HH:mm"
    }
}

// MARK: - DailySleep (View Data)
public struct DailySleep: Identifiable {
    public let id = UUID()
    public let day: Int
    public let date: Date
    public let weekday: String
    public let hours: Int?
    public let minutes: Int?

    public var totalHours: Double {
        Double(hours ?? 0) + Double(minutes ?? 0) / 60
    }

    public init(day: Int, date: Date, weekday: String, hours: Int?, minutes: Int?) {
        self.day = day
        self.date = date
        self.weekday = weekday
        self.hours = hours
        self.minutes = minutes
    }
}

// MARK: - Weekly View Model
public struct WeeklySleepStatsModel: SleepStats {
    public let startDate: Date
    public let endDate: Date
    public let daily: [DailySleep]
    public let averageHours: Int?
    public let averageMinutes: Int?

    // 포맷터 & 캘린더 재사용
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
    private static let koreanWeekdays = ["일","월","화","수","목","금","토"]

    /// response → UI용 모델 변환
    public init(
        from response: WeeklySleepResponse,
        calendar: Calendar = .current
    ) {
        self.startDate = response.startDate
        self.endDate   = response.endDate

        // 평균 분 → 시/분
        let total = response.averageSleepMinutes
        self.averageHours   = total / 60
        self.averageMinutes = total % 60

        // dailySleepRecords → DailySleep 배열
        self.daily = response.dailySleepRecords.map { record in
            let start = Self.formatter.date(from: record.sleepStartTime) ?? Date()
            let end   = Self.formatter.date(from: record.wakeUpTime)    ?? Date()
            var interval = end.timeIntervalSince(start)
            if interval < 0 { interval += 24 * 3600 }
            let hrs  = Int(interval / 3600)
            let mins = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)

            let idx = calendar.component(.weekday, from: record.date) - 1
            let kwd = Self.koreanWeekdays[idx]

            return DailySleep(
                day:     record.day,
                date:    record.date,
                weekday: kwd,
                hours:   hrs,
                minutes: mins
            )
        }
    }
}

// MARK: - Monthly DTO
public struct MonthlySleepResponse: Decodable {
    public let startDate: Date
    public let endDate: Date
    public let averageSleepMinutes: Int
    public let weeklySleepRecords: [WeeklyRecord]

    public struct WeeklyRecord: Decodable {
        public let week: Int
        public let sleepStartTime: String
        public let wakeUpTime: String
    }
}

// MARK: - Monthly View Model
public struct MonthlySleepStatsModel: SleepStats {
    public let startDate: Date
    public let endDate: Date
    public let weekly: [WeeklySleep]
    public let averageHours: Int?
    public let averageMinutes: Int?

    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    public init(from response: MonthlySleepResponse) {
        self.startDate = response.startDate
        self.endDate   = response.endDate

        let total = response.averageSleepMinutes
        self.averageHours   = total / 60
        self.averageMinutes = total % 60

        self.weekly = response.weeklySleepRecords.map { rec in
            let start = Self.formatter.date(from: rec.sleepStartTime) ?? Date()
            let end   = Self.formatter.date(from: rec.wakeUpTime)    ?? Date()
            var interval = end.timeIntervalSince(start)
            if interval < 0 { interval += 24 * 3600 }
            let hrs  = Int(interval / 3600)
            let mins = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            return WeeklySleep(week: "\(rec.week)", hours: hrs, minutes: mins)
        }
    }
}

// 재사용 가능한 주간 단위 모델
public struct WeeklySleep: Identifiable {
    public let id = UUID()
    public let week: String
    public let hours: Int?
    public let minutes: Int?
    public var totalHours: Double {
        Double(hours ?? 0) + Double(minutes ?? 0) / 60
    }
}
