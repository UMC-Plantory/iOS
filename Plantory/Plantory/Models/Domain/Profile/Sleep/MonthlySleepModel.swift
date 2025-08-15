import Foundation

// MARK: - Monthly DTO & Model
// 서버 응답과 1:1 타입/키로 받기
public struct MonthlySleepResponse: Codable {
    public let startDate: String              // "yyyy-MM-dd"
    public let endDate: String                // "yyyy-MM-dd"
    public let averageSleepMinutes: Int
    public let weeklySleepRecords: [WeeklyRecord]

    public struct WeeklyRecord: Codable {
        public let week: Int
        public let averageSleepStartTime: String   // "HH:mm:ss"
        public let averageSleepEndTime: String     // "HH:mm:ss"
    }
}

// DTO → UI 모델 변환
public struct MonthlySleepStatsModel: SleepStats {
    public let startDate: Date
    public let endDate: Date
    public let weekly: [WeeklyInterval]
    public let averageHours: Int?
    public let averageMinutes: Int?

    private static let ymd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    private static let hms: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df
    }()

    public init(from response: MonthlySleepResponse, calendar: Calendar = .current) {
        // 기간 파싱
        let s = Self.ymd.date(from: response.startDate)!
        let e = Self.ymd.date(from: response.endDate)!
        self.startDate = s
        self.endDate   = e

        // 평균 분 → 시/분
        let totalMin = response.averageSleepMinutes
        self.averageHours   = totalMin / 60
        self.averageMinutes = totalMin % 60

        // 기준일(앵커): 통계 시작일 00:00
        let baseDay = calendar.startOfDay(for: s)

        // 주별 레코드 변환
        self.weekly = response.weeklySleepRecords.compactMap { rec in
            guard
                let compStart = Self.hms.date(from: rec.averageSleepStartTime),
                let compEnd   = Self.hms.date(from: rec.averageSleepEndTime)
            else { return nil }

            // 기상 시각(초=0으로 정규화)
            let endDT = calendar.date(
                bySettingHour: calendar.component(.hour, from: compEnd),
                minute:        calendar.component(.minute, from: compEnd),
                second:        0,
                of:            baseDay
            )!

            // 취침 시각(초=0으로 정규화) + 자정 교차 보정
            let tentative = calendar.date(
                bySettingHour: calendar.component(.hour, from: compStart),
                minute:        calendar.component(.minute, from: compStart),
                second:        0,
                of:            baseDay
            )!
            let startDT = tentative <= endDT ? tentative
                                             : calendar.date(byAdding: .day, value: -1, to: tentative)!

            return WeeklyInterval(
                week: "\(rec.week)",
                startTime: startDT,
                endTime:   endDT
            )
        }
    }
}


/// UI 표시용 주별 수면 요약 모델
public struct WeeklyInterval: Identifiable {
    public let id = UUID()
    public let week: String       // "1", "2", ...
    public let startTime: Date    // 실제 취침 시각 (날짜 포함)
    public let endTime: Date      // 실제 기상 시각 (날짜 포함)
}
