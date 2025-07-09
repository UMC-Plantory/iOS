/// SleepModel.swift
///
/// 이 파일은 수면 통계 관련 도메인 모델과 DTO(응답 데이터)를 정의합니다.
/// 1. SleepStats 프로토콜: 평균 수면 정보와 코멘트 제공
/// 2. WeeklySleepResponse, MonthlySleepResponse: 서버 응답을 디코딩하는 DTO
/// 3. WeeklySleepStatsModel, MonthlySleepStatsModel: 뷰에서 사용할 모델
/// 4. DailySleep, WeeklySleep: 차트 렌더링용 식별 가능한 모델

import Foundation

// MARK: - 공통 프로토콜
/// 평균 수면 시간(hours, minutes)을 제공하는 프로토콜
public protocol SleepStats {
    /// 평균 수면 시간(시간 단위) - 시
    var averageHours: Int?    { get }
    /// 평균 수면 시간(시간 단위) - 분
    var averageMinutes: Int?  { get }
}

public extension SleepStats {
    /// totalHours: 평균 수면 시간을 시간 단위 소수로 변환
    var totalHours: Double {
        Double(averageHours ?? 0) + Double(averageMinutes ?? 0) / 60
    }

    /// comment: 총 수면 시간에 따라 보여줄 추천 멘트 생성
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

// MARK: - Weekly DTO (WeeklySleepResponse)
/// 서버에서 주간 수면 통계 응답을 디코딩하기 위한 구조체
public struct WeeklySleepResponse: Decodable {
    /// 통계 기간 시작일
    public let startDate: Date
    /// 통계 기간 종료일
    public let endDate: Date
    /// 일별 수면 데이터 배열
    public let daily: [DailyEntry]
    /// 주간 평균 수면 시간 정보
    public let average: AverageEntry

    /// 일별 수면 데이터 DTO
    public struct DailyEntry: Decodable, Identifiable {
        /// 내부 식별자(UUID)
        public let id: UUID
        /// 해당 일자
        public let date: Date
        /// 수면 시(0~23)
        public let hours: Int?
        /// 수면 분(0~59)
        public let minutes: Int?

        enum CodingKeys: String, CodingKey {
            case date, hours, minutes
        }

        /// 디코딩 초기화: UUID 자동 생성
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.date    = try container.decode(Date.self, forKey: .date)
            self.hours   = try container.decodeIfPresent(Int.self, forKey: .hours)
            self.minutes = try container.decodeIfPresent(Int.self, forKey: .minutes)
            self.id      = UUID()
        }
    }

    /// 주간 평균 수면 시간 DTO
    public struct AverageEntry: Decodable {
        public let hours: Int?
        public let minutes: Int?
    }
}

// MARK: - Weekly View Model (WeeklySleepStatsModel)
/// WeeklySleepResponse를 UI 렌더링용 모델로 변환
public struct WeeklySleepStatsModel: SleepStats {
    public let startDate: Date    // 통계 기간 시작일
    public let endDate: Date      // 통계 기간 종료일
    public let daily: [DailySleep] // 변환된 일별 데이터
    public let averageHours: Int? // 평균 시간(시)
    public let averageMinutes: Int? // 평균 시간(분)

    /// 초기화: DTO → 뷰 모델 변환
    public init(from response: WeeklySleepResponse) {
        self.startDate      = response.startDate
        self.endDate        = response.endDate
        self.averageHours   = response.average.hours
        self.averageMinutes = response.average.minutes

        let calendar = Calendar.current
        let symbols = calendar.weekdaySymbols.map { String($0.first!) }
        // 일자별 정렬 후 DailySleep으로 변환
        self.daily = response.daily
            .sorted { $0.date < $1.date }
            .map {
                let dayIndex = calendar.component(.weekday, from: $0.date) - 1
                return DailySleep(
                    date: $0.date,
                    weekday: symbols[dayIndex],
                    hours: $0.hours,
                    minutes: $0.minutes
                )
            }
    }
}

// MARK: - Daily Sleep Model
/// 차트 렌더링용 일별 수면 정보
public struct DailySleep: Identifiable {
    public let id = UUID()       // 식별자
    public let date: Date        // 해당 일자
    public let weekday: String   // 요일 ("일","월",...)
    public let hours: Int?       // 수면 시
    public let minutes: Int?     // 수면 분

    /// displayText: "7h 40m" 또는 데이터 없음 시 "—"
    public var displayText: String {
        guard let h = hours, let m = minutes else { return "—" }
        return "\(h)h \(m)m"
    }
}

// MARK: - Monthly DTO (MonthlySleepResponse)
/// 서버에서 월간 수면 통계 응답을 디코딩하기 위한 구조체
public struct MonthlySleepResponse: Decodable {
    public let startDate: Date   // 통계 기간 시작일
    public let endDate: Date     // 통계 기간 종료일
    public let weekly: [WeeklyEntry] // 주 단위 데이터
    public let average: AverageEntry  // 월간 평균 수면 정보

    /// 주 단위 수면 데이터 DTO
    public struct WeeklyEntry: Decodable, Identifiable {
        public let id: UUID
        public let week: String     // "1주차" 형식
        public let hours: Int?
        public let minutes: Int?

        enum CodingKeys: String, CodingKey {
            case week, hours, minutes
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.week    = try container.decode(String.self, forKey: .week)
            self.hours   = try container.decodeIfPresent(Int.self, forKey: .hours)
            self.minutes = try container.decodeIfPresent(Int.self, forKey: .minutes)
            self.id      = UUID()
        }
    }

    /// 월간 평균 수면 시간 DTO
    public struct AverageEntry: Decodable {
        public let hours: Int?
        public let minutes: Int?
    }
}

// MARK: - Weekly Sleep Model
/// MonthlySleepResponse → 뷰 렌더링용 주간 수면 정보 변환
public struct WeeklySleep: Identifiable {
    public let id = UUID()
    public let week: String     // "1주차"
    public let hours: Int?
    public let minutes: Int?

    /// totalHours: 주 단위 총 수면 시간(소수)
    public var totalHours: Double {
        Double(hours ?? 0) + Double(minutes ?? 0) / 60
    }
}

// MARK: - Monthly View Model (MonthlySleepStatsModel)
/// MonthlySleepResponse를 UI 모델로 변환
public struct MonthlySleepStatsModel: SleepStats {
    public let startDate: Date      // 기간 시작일
    public let endDate: Date        // 기간 종료일
    public let weekly: [WeeklySleep] // 변환된 주 단위 데이터
    public let averageHours: Int?   // 월간 평균 시
    public let averageMinutes: Int? // 월간 평균 분

    /// 초기화: DTO → 뷰 모델 변환
    public init(from response: MonthlySleepResponse) {
        self.startDate      = response.startDate
        self.endDate        = response.endDate
        self.averageHours   = response.average.hours
        self.averageMinutes = response.average.minutes
       
        // WeeklyEntry → WeeklySleep 변환
        self.weekly = response.weekly.map {
            WeeklySleep(
                week: $0.week,
                hours: $0.hours,
                minutes: $0.minutes
            )
        }
    }
}
