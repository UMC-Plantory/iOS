import Moya
import Combine
import Foundation

enum SleepAPI: APITargetType {
    case weeklyStats
}

extension SleepAPI {
    var baseURL: URL { URL(string: "https://example.com")! }
    var path: String {
        switch self {
        case .weeklyStats: return "/sleep/weekly"
        }
    }
    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
    var sampleData: Data {
        let json = """
        {
          "startDate": "2025-07-02",
          "endDate": "2025-07-08",
          "daily": [
            { "date": "2025-07-02", "hours": 7, "minutes": 40 },
            { "date": "2025-07-03", "hours": 8, "minutes": 10 },
            { "date": "2025-07-04", "hours": 6, "minutes": 55 },
            { "date": "2025-07-05", "hours": null, "minutes": null  },
            { "date": "2025-07-06", "hours": 7, "minutes": 30 },
            { "date": "2025-07-07", "hours": null, "minutes": null  },
            { "date": "2025-07-08", "hours": 8, "minutes":  0 }
          ],
          "average": { "hours": 8, "minutes": 15 }
        }
        """
        return Data(json.utf8)
    }
}

// MARK: - JSONDecoder Extension for 날짜 디코딩
// Date 디코딩 설정
extension JSONDecoder {
    static var customDateDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        // 날짜 형식이 "yyyy-MM-dd" 라면:
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(fmt)
        return decoder
    }
}

// MARK: - SleepAPI Provider Extension
extension MoyaProvider where Target == SleepAPI {
    func fetchWeeklyStats() -> AnyPublisher<WeeklySleepResponse, MoyaError> {
        requestPublisher(.weeklyStats)
            .filterSuccessfulStatusCodes()
            .map(WeeklySleepResponse.self, using: JSONDecoder.customDateDecoder)
            .eraseToAnyPublisher()
    }
}
