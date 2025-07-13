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
/// 서버 주간 수면 통계 응답 모델
public struct WeeklySleepResponse: Decodable {
    public let startDate: Date        // 통계 기간 시작일
    public let endDate: Date          // 통계 기간 종료일
    public let averageSleepMinutes: Int // 평균 수면 시간(분)
    public let dailySleepRecords: [DailySleepRecord] // 일별 수면 레코드

    public struct DailySleepRecord: Decodable {
        public let day: Int             // 주 내 순번 (1~7)
        public let date: Date           // 해당 날짜 (기상일)
        public let sleepStartTime: String // 취침 시각 문자열 ("HH:mm")
        public let wakeUpTime: String     // 기상 시각 문자열 ("HH:mm")
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
    public let startDate: Date      // 통계 시작일
    public let endDate: Date        // 통계 종료일
    public let daily: [DailySleep]  // 변환된 일별 수면 데이터
    public let averageHours: Int?   // 평균 수면 시
    public let averageMinutes: Int? // 평균 수면 분

    /// 내부 DateFormatter: "HH:mm" 형식 파싱용
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
    /// 요일 매핑용 (Calendar.weekday 기준)
    private static let weekdaysKR = ["일","월","화","수","목","금","토"]

    /**
     초기화:
     - 응답 DTO로부터 날짜 계산 및 평균 시간 분리 로직 수행
     */
    public init(from response: WeeklySleepResponse, calendar: Calendar = .current) {
        self.startDate = response.startDate
        self.endDate   = response.endDate

        // 평균 시간을 시/분으로 분리
        let totalMin = response.averageSleepMinutes
        self.averageHours   = totalMin / 60
        self.averageMinutes = totalMin % 60

        // 일별 레코드를 DailySleep으로 변환
        self.daily = response.dailySleepRecords.map { rec in
            // HH:mm 문자열을 Date 타입으로 변환
            let compStart = Self.formatter.date(from: rec.sleepStartTime)!
            let compEnd   = Self.formatter.date(from: rec.wakeUpTime)!
            let dayStart  = calendar.startOfDay(for: rec.date)

            // 기상 시각: rec.date 기준에 시간 설정
            let endDT = calendar.date(
                bySettingHour: calendar.component(.hour, from: compEnd),
                minute: calendar.component(.minute, from: compEnd),
                second: 0,
                of: dayStart
            )!
            // 취침 시각 계산: endDT보다 늦으면 전날로 조정
            let tentative = calendar.date(
                bySettingHour: calendar.component(.hour, from: compStart),
                minute: calendar.component(.minute, from: compStart),
                second: 0,
                of: dayStart
            )!
            let startDT = tentative <= endDT
                ? tentative
                : calendar.date(byAdding: .day, value: -1, to: tentative)!

            // 요일 한글 매핑
            let idx = calendar.component(.weekday, from: rec.date) - 1
            let kw = Self.weekdaysKR[idx]

            return DailySleep(
                day: rec.day,
                date: rec.date,
                weekday: kw,
                startTime: startDT,
                endTime: endDT
            )
        }
    }
}

// MARK: - Monthly DTO & Model
/// 서버 월간 수면 통계 응답 모델
public struct MonthlySleepResponse: Decodable {
    public let startDate: Date
    public let endDate: Date
    public let averageSleepMinutes: Int
    public let weeklySleepRecords: [WeeklyRecord]

    public struct WeeklyRecord: Decodable {
        public let week: Int            // 순번 (1~4)
        public let sleepStartTime: String // 취침 시각
        public let wakeUpTime: String     // 기상 시각
    }
}

/// 월간 통계 모델: DTO → UI 모델(WeeklySleep)로 변환
public struct MonthlySleepStatsModel: SleepStats {
    public let startDate: Date
    public let endDate: Date
    public let weekly: [WeeklySleep] // 주별 요약 데이터
    public let averageHours: Int?    // 평균 시
    public let averageMinutes: Int?  // 평균 분

    /// HH:mm 파싱용
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    /**
     초기화: 날짜 및 평균 시간 계산,
     주별 수면 간격 계산 로직 포함
     */
    public init(from response: MonthlySleepResponse) {
        self.startDate  = response.startDate
        self.endDate    = response.endDate

        // 평균 시간 분리
        let totalMin = response.averageSleepMinutes
        self.averageHours   = totalMin / 60
        self.averageMinutes = totalMin % 60

        // 주별 기록을 WeeklySleep 모델로 변환
        self.weekly = response.weeklySleepRecords.map { rec in
            // 문자열 → Date
            let compStart = Self.formatter.date(from: rec.sleepStartTime)!
            let compEnd   = Self.formatter.date(from: rec.wakeUpTime)!
            // 시간 간격 계산, 음수 시 24h 보정
            var interval = compEnd.timeIntervalSince(compStart)
            if interval < 0 { interval += 24 * 3600 }
            // 시/분 분리
            let hrs  = Int(interval / 3600)
            let mins = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            return WeeklySleep(week: "\(rec.week)", hours: hrs, minutes: mins)
        }
    }
}

/// UI 표시용 주별 수면 요약 모델
public struct WeeklySleep: Identifiable {
    public let id = UUID()          // 고유 식별자
    public let week: String         // 주차 ("1","2",...)
    public let hours: Int?          // 수면 시간(시)
    public let minutes: Int?        // 수면 시간(분)
    /// 총 수면 시간을 시간(Double) 단위로 반환
    public var totalHours: Double { Double(hours ?? 0) + Double(minutes ?? 0) / 60 }
}
