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

public enum SortOrder: String {
        case oldest
        case latest
}

// MARK: - ProfileRouter Provider Extension
extension MoyaProvider where Target == ProfileRouter {
    // 공통 JSON 디코딩 + 상태 코드 필터링 파이프라인
    private func requestDecoded<Response: Decodable>(
        _ target: ProfileRouter,
        as type: Response.Type
    ) -> AnyPublisher<Response, MoyaError> {
        requestPublisher(target)
            .filterSuccessfulStatusCodes()
            .map(type, using: JSONDecoder.customDateDecoder)
            .eraseToAnyPublisher()
    }

    func fetchWeeklyStats() -> AnyPublisher<WeeklySleepResponse, MoyaError> {
        requestDecoded(.weeklyStats, as: WeeklySleepResponse.self)
    }

    func fetchMonthlyStats() -> AnyPublisher<MonthlySleepResponse, MoyaError> {
        requestDecoded(.monthlyStats, as: MonthlySleepResponse.self)
    }

    func fetchWeeklyEmotionStats() -> AnyPublisher<WeeklyEmotionResponse, MoyaError> {
        requestDecoded(.weeklyEmotionStats, as: WeeklyEmotionResponse.self)
    }

    func fetchTemp(sort: SortOrder = .latest) -> AnyPublisher<[Diary], MoyaError> {
        requestDecoded(.temporary(sort: sort.rawValue), as: TempResponse.self)
            .map { $0.diaries }
            .eraseToAnyPublisher()
    }

    func fetchWaste(sort: SortOrder = .latest) -> AnyPublisher<[Diary], MoyaError> {
        requestDecoded(.waste(sort: sort.rawValue), as: WasteResponse.self)
            .map { $0.diaries }
            .eraseToAnyPublisher()
    }
    
    func deleteWaste(diaryIds: [Int]) -> AnyPublisher<WastePatchResponse, MoyaError> {
        requestDecoded(.wastePatch(diaryIds: diaryIds), as: WastePatchResponse.self)
    }
}

