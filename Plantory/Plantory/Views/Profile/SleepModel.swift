// SleepModel.swift
import Foundation

// MARK: - Weekly Model
/// 서버 응답을 바로 디코딩할 DTO
public struct WeeklySleepResponse: Decodable {
    public let startDate: Date
    public let endDate: Date
    public let daily: [DailyEntry]
    public let average: AverageEntry

    public struct DailyEntry: Decodable, Identifiable {
        public let id: UUID
        public let date: Date
        public let hours: Int?
        public let minutes: Int?

        enum CodingKeys: String, CodingKey {
            case date, hours, minutes
        }

        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.date    = try c.decode(Date.self,    forKey: .date)
            self.hours   = try c.decodeIfPresent(Int.self, forKey: .hours)
            self.minutes = try c.decodeIfPresent(Int.self, forKey: .minutes)
            self.id      = UUID()
        }
    }

    public struct AverageEntry: Decodable {
        public let hours: Int?
        public let minutes: Int?
    }

    enum CodingKeys: String, CodingKey {
        case startDate, endDate, daily, average
    }
}

/// 뷰에서 쓸 도메인 모델
public struct DailySleep: Identifiable {
    public let id = UUID()
    public let date: Date
    public let weekday: String      // "일","월"...
    public let hours: Int?          // 0~23
    public let minutes: Int?        // 0~59

    /// 시각 표시용: "7h 40m", "6h 0m", "—"
    public var displayText: String {
        guard let h = hours, let m = minutes else { return "—" }
        return "\(h)h \(m)m"
    }
}

/// WeeklySleepResponse → DailySleep 변환기
public struct WeeklySleepStatsModel {
    public let startDate: Date
    public let endDate: Date
    public let daily: [DailySleep]
    public let averageHours: Int?
    public let averageMinutes: Int?

    public init(from resp: WeeklySleepResponse) {
        self.startDate      = resp.startDate
        self.endDate        = resp.endDate
        self.averageHours   = resp.average.hours
        self.averageMinutes = resp.average.minutes

        let cal = Calendar.current
        let symbols = cal.weekdaySymbols.map { String($0.first!) }
        let sorted = resp.daily.sorted { $0.date < $1.date }

        self.daily = sorted.map { entry in
            let wd = symbols[cal.component(.weekday, from: entry.date) - 1]
            return DailySleep(
                date: entry.date,
                weekday: wd,
                hours: entry.hours,
                minutes: entry.minutes
            )
        }
    }
}

// MARK: - Monthly Model
/// 서버 응답을 바로 디코딩할 DTO
public struct MonthlySleepResponse: Decodable {
    public let startDate: Date
    public let endDate: Date
    public let weekly: [WeeklyEntry]
    public let average: AverageEntry
    
    public struct WeeklyEntry: Decodable, Identifiable {
        public let id: UUID
        public let week: String
        public let hours: Int?
        public let minutes: Int?
        
        enum CodingKeys: String, CodingKey {
            case week, hours, minutes
        }
        
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.week = try c.decode(String.self, forKey: .week)
            self.hours = try c.decodeIfPresent(Int.self, forKey: .hours)
            self.minutes = try c.decodeIfPresent(Int.self, forKey: .minutes)
            self.id = UUID()
        }
    }
    
    public struct AverageEntry: Decodable {
        public let hours: Int?
        public let minutes: Int?
    }
    
    enum CodingKeys: String, CodingKey {
        case startDate, endDate, weekly, average
    }
}

///뷰에서 쓸 도메인 모델
public struct WeeklySleep: Identifiable {
    public let id = UUID()
    public let week: String
    public let hours: Int?
    public let minutes: Int?
    
    /// 시각 표시용: "7h 40m", "6h 0m", "—"
    public var displayText: String {
        guard let h = hours, let m = minutes else { return "—" }
        return "\(h)h \(m)m"
    }
}

/// MonthlySleepResponse → WeeklySleep 변환기
public struct MonthlySleepStatsModel {
    public let startDate: Date
    public let endDate: Date
    public let weekly: [WeeklySleep]
    public let averageHours: Int?
    public let averageMinutes: Int?
    
    public init(from resp: MonthlySleepResponse) {
        self.startDate = resp.startDate
        self.endDate = resp.endDate
        self.averageHours = resp.average.hours
        self.averageMinutes = resp.average.minutes
        
        self.weekly = resp.weekly.map {
            WeeklySleep(
                week: $0.week,
                hours: $0.hours,
                minutes: $0.minutes
            )
        }
    }
}
