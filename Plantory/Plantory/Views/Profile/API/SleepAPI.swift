import Moya
import Combine
import Foundation

enum SleepAPI: APITargetType {
    case weeklyStats
    case monthlyStats
}

extension SleepAPI {
    var baseURL: URL {
        URL(string: "https://example.com")!
    }

    var path: String {
        switch self {
        case .weeklyStats: return "/sleep/weekly"
        case .monthlyStats: return "/sleep/monthly"
        }
    }

    var method: Moya.Method {
        switch self {
        case .weeklyStats, .monthlyStats:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .weeklyStats, .monthlyStats:
            return .requestPlain
        }
    }

    var sampleData: Data {
        let json: String

        switch self {
        case .weeklyStats:
            json = """
            {
              "startDate": "2025-07-02",
              "endDate": "2025-07-08",
              "daily": [
                { "date": "2025-07-02", "hours": 7, "minutes": 40 },
                { "date": "2025-07-03", "hours": 8, "minutes": 10 },
                { "date": "2025-07-04", "hours": 6, "minutes": 55 },
                { "date": "2025-07-05", "hours": null, "minutes": null },
                { "date": "2025-07-06", "hours": 7, "minutes": 30 },
                { "date": "2025-07-07", "hours": null, "minutes": null },
                { "date": "2025-07-08", "hours": 8, "minutes": 0 }
              ],
              "average": { "hours": 8, "minutes": 15 }
            }
            """
        case .monthlyStats:
            json = """
            {
              "startDate": "2025-06-01",
              "endDate": "2025-06-30",
              "weekly": [
                { "week": "1주차", "hours": 7, "minutes": 10 },
                { "week": "2주차", "hours": 6, "minutes": 45 },
                { "week": "3주차", "hours": 7, "minutes": 50 },
                { "week": "4주차", "hours": 7, "minutes": 30 },
                { "week": "5주차", "hours": 7, "minutes": 10 }
              ],
              "average": { "hours": 7, "minutes": 24 }
            }
            """
        }

        return Data(json.utf8)
    }
}

// MARK: - JSONDecoder Extension for 날짜 디코딩
extension JSONDecoder {
    static var customDateDecoder: JSONDecoder {
        let decoder = JSONDecoder()
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

    func fetchMonthlyStats() -> AnyPublisher<MonthlySleepResponse, MoyaError> {
        requestPublisher(.monthlyStats)
            .filterSuccessfulStatusCodes()
            .map(MonthlySleepResponse.self, using: JSONDecoder.customDateDecoder)
            .eraseToAnyPublisher()
    }
}
