import Moya
import Combine
import Foundation

enum ProfileRouter: APITargetType {
    case weeklyStats
    case monthlyStats
    case weeklyEmotionStats
    case temporary(sort: String)
    case waste
}

extension ProfileRouter {
    var baseURL: URL {
        URL(string: "https://example.com")!
    }

    var path: String {
        switch self {
        case .weeklyStats:
            return "/sleep/weekly"
        case .monthlyStats:
            return "/sleep/monthly"
        case .weeklyEmotionStats:
            return "/emotion/weekly"
        case .temporary:
            return "/diary/temp"
        case .waste:
            return "/diary/waste"
        }
    }

    var method: Moya.Method {
        switch self {
        case .weeklyStats, .monthlyStats, .weeklyEmotionStats, .temporary:
            return .get
        case .waste:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .weeklyStats, .monthlyStats, .weeklyEmotionStats, .waste:
            return .requestPlain
            
        case .temporary(let sort):
                return .requestParameters(
                        parameters: ["sort": sort],
                        encoding: URLEncoding.default
                )
        }
    }

    var sampleData: Data {
        let json: String

        switch self {
        case .weeklyStats:
            json = """
            {
              "startDate": "2025-06-15",
              "endDate": "2025-06-21",
              "todayWeekday": "Wednesday",
              "averageSleepMinutes": 380,
              "dailySleepRecords": [
                {
                  "day": 1,
                  "date": "2025-06-18",
                  "weekday": "Wednesday",
                  "sleepStartTime": "00:30",
                  "wakeUpTime": "06:45"
                },
                {
                  "day": 2,
                  "date": "2025-06-19",
                  "weekday": "Thursday",
                  "sleepStartTime": "00:00",
                  "wakeUpTime": "00:00"
                },
                {
                  "day": 3,
                  "date": "2025-06-20",
                  "weekday": "Friday",
                  "sleepStartTime": "02:00",
                  "wakeUpTime": "08:00"
                },
                {
                  "day": 4,
                  "date": "2025-06-21",
                  "weekday": "Saturday",
                  "sleepStartTime": "01:10",
                  "wakeUpTime": "07:30"
                },
                {
                  "day": 5,
                  "date": "2025-06-15",
                  "weekday": "Sunday",
                  "sleepStartTime": "00:50",
                  "wakeUpTime": "06:30"
                },
                {
                  "day": 6,
                  "date": "2025-06-16",
                  "weekday": "Monday",
                  "sleepStartTime": "00:00",
                  "wakeUpTime": "00:00"
                },
                {
                  "day": 7,
                  "date": "2025-06-17",
                  "weekday": "Tuesday",
                  "sleepStartTime": "01:20",
                  "wakeUpTime": "07:10"
                }
              ]
            }
            """

        case .monthlyStats:
            json = """
            {
              "startDate": "2025-06-01",
              "endDate": "2025-06-30",
              "todayWeekday": "Monday",
              "averageSleepMinutes": 444,
              "weeklySleepRecords": [
                {
                  "week": 1,
                  "sleepStartTime": "01:10",
                  "wakeUpTime": "08:00"
                },
                {
                  "week": 2,
                  "sleepStartTime": "00:45",
                  "wakeUpTime": "07:10"
                },
                {
                  "week": 3,
                  "sleepStartTime": "23:50",
                  "wakeUpTime": "06:30"
                },
                {
                  "week": 4,
                  "sleepStartTime": "00:30",
                  "wakeUpTime": "07:15"
                },
                {
                  "week": 5,
                  "sleepStartTime": "01:00",
                  "wakeUpTime": "08:05"
                }
              ]
            }
            """

        case .weeklyEmotionStats:
            json = """
            {
              "startDate": "2025-06-08",
              "endDate": "2025-06-14",
              "stats": [
                { "emotion": "기쁨", "percentage": 45 },
                { "emotion": "놀람", "percentage": 15 },
                { "emotion": "슬픔", "percentage": 20 },
                { "emotion": "화남", "percentage": 5 },
                { "emotion": "그저그럼", "percentage": 15 }
              ],
              "comment": "기쁨"
            }
            """

        case .temporary:
            json = """
    {
      "isSuccess": true,
      "code": 200,
      "message": "임시보관한 일기 목록 조회 성공",
      "result": {
        "diaries": [
          { "id": 1, "date": "2025-06-20", "title": "일기 제목 1" },
          { "id": 2, "date": "2025-06-21", "title": "일기 제목 2" },
          { "id": 3, "date": "2025-06-22", "title": "일기 제목 3" },
          { "id": 4, "date": "2025-06-23", "title": "일기 제목 4" },
          { "id": 5, "date": "2025-06-24", "title": "일기 제목 5" },
          { "id": 6, "date": "2025-06-25", "title": "일기 제목 6" },
          { "id": 7, "date": "2025-06-26", "title": "일기 제목 7" },
          { "id": 8, "date": "2025-06-27", "title": "일기 제목 8" },
          { "id": 9, "date": "2025-06-28", "title": "일기 제목 9" },
          { "id": 10, "date": "2025-06-29", "title": "일기 제목 10" }
        ]
      }
    }
    """
        case .waste:
            json = """
            {
              "id": 1,
              "date": "2025-06-22",
              "status": "waste",
              "message": "쓰레기 처리 완료"
            }
            """
        }

        return Data(json.utf8)
    }
}
