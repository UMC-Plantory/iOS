//
// ProfileService.swift
//
// Moya와 Combine을 사용하여 수면 통계 API를 호출하고, JSONDecoder 확장으로 날짜 디코딩을 통일합니다.

import Moya
import Combine
import Foundation

// MARK: - JSONDecoder Extension for 날짜 디코딩
extension JSONDecoder {
    /// 서버에서 "yyyy-MM-dd" 형식의 날짜 문자열을 디코딩할 때 사용하는 커스텀 decoder
    static var customDateDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let fmt = DateFormatter()
        // 날짜 포맷 설정: 예) "2025-07-09"
        fmt.dateFormat = "yyyy-MM-dd"
        // 디코딩 전략에 포맷터 적용
        decoder.dateDecodingStrategy = .formatted(fmt)
        return decoder
    }
}

// MARK: - ProfileRouter Provider Extension
extension MoyaProvider where Target == ProfileRouter {
    /// 주간 수면 통계 API 호출
    /// - 반환: WeeklySleepResponse를 발행하는 AnyPublisher
    func fetchWeeklyStats() -> AnyPublisher<WeeklySleepResponse, MoyaError> {
        return requestPublisher(.weeklyStats)
            // HTTP 2xx 상태 코드만 통과
            .filterSuccessfulStatusCodes()
            // JSONDecoder.customDateDecoder를 사용해 WeeklySleepResponse로 매핑
            .map(WeeklySleepResponse.self, using: JSONDecoder.customDateDecoder)
            // Combine Publisher 타입 통일
            .eraseToAnyPublisher()
    }

    /// 월간 수면 통계 API 호출
    /// - 반환: MonthlySleepResponse를 발행하는 AnyPublisher
    func fetchMonthlyStats() -> AnyPublisher<MonthlySleepResponse, MoyaError> {
        return requestPublisher(.monthlyStats)
            // HTTP 2xx 상태 코드만 통과
            .filterSuccessfulStatusCodes()
            // JSONDecoder.customDateDecoder를 사용해 MonthlySleepResponse로 매핑
            .map(MonthlySleepResponse.self, using: JSONDecoder.customDateDecoder)
            // Combine Publisher 타입 통일
            .eraseToAnyPublisher()
    }
    
    func weeklyEmotionStats() -> AnyPublisher<WeeklyEmotionResponse, MoyaError> {
        return requestPublisher(.weeklyEmotionStats)
            .filterSuccessfulStatusCodes()
            .map(WeeklyEmotionResponse.self, using: JSONDecoder.customDateDecoder)
            .eraseToAnyPublisher()
    }
}
