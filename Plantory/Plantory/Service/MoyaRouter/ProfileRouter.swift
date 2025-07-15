import Moya
import Combine
import Foundation

/// API 라우터 정의
enum ProfileRouter: APITargetType {
    case weeklyStats
    case monthlyStats
    case weeklyEmotionStats
    case temporary(sort: String)
    case waste(sort: String)
    case wastePatch(diaryIds: [Int])
    case deleteDiary(diaryIds: [Int])
    case patchProfile(memberId: UUID, name: String, profileImgUrl: String, gender: String, birth: String)
}

extension ProfileRouter {
    /// 기본 URL 설정
    var baseURL: URL {
        URL(string: "https://example.com")!
    }

    /// 각 케이스별 요청 경로
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
        case .waste, .wastePatch:
            return "/diary/waste"
        case .deleteDiary:
            return "/diary"
        case .patchProfile:
            return "/member/profile"
        }
    }

    /// HTTP 메서드 설정
    var method: Moya.Method {
        switch self {
        case .wastePatch, .patchProfile:
            return .patch
        case .deleteDiary:
            return .delete
        default:
            return .get
        }
    }

    /// 요청 Task 설정 (파라미터 인코딩)
    var task: Task {
        switch self {
        // GET: 본문 없이
        case .weeklyStats, .monthlyStats, .weeklyEmotionStats:
            return .requestPlain

        // GET: sort 쿼리 파라미터
        case .temporary(let sort), .waste(let sort):
            return .requestParameters(
                parameters: ["sort": sort],
                encoding: URLEncoding.default
            )

        // PATCH: diaryIds JSON body
        case .wastePatch(let diaryIds), .deleteDiary(let diaryIds):
            return .requestParameters(
                parameters: ["diaryIds": diaryIds],
                encoding: JSONEncoding.default
            )
        
        // PATCH: patchProfile JSON body
        case .patchProfile(let memberId, let name, let profileImgUrl, let gender, let birth):
            return .requestParameters(
                parameters: [
                    "memberId":      memberId.uuidString,  // UUID → String
                    "name":          name,
                    "profileImgUrl": profileImgUrl,
                    "gender":        gender,
                    "birth":         birth               // "YYYY-MM-DD"
                ],
                encoding: JSONEncoding.default
            )
        }
    }

    /// 요청 헤더
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    /// 샘플 데이터 (Preview/Test용)
    var sampleData: Data {
        let json: String
        switch self {
        case .weeklyStats:
            json = """
            {
              "startDate": "2025-06-15",
              "endDate": "2025-06-21",
              "todayWeekday": "Saturday",
              "averageSleepMinutes": 420,
              "dailySleepRecords": [
                { "day": 1, "date": "2025-06-15", "weekday": "Saturday",  "sleepStartTime": "00:30", "wakeUpTime": "07:30" },
                { "day": 2, "date": "2025-06-16", "weekday": "Sunday",    "sleepStartTime": "23:45", "wakeUpTime": "06:45" },
                { "day": 3, "date": "2025-06-17", "weekday": "Monday",    "sleepStartTime": "00:15", "wakeUpTime": "07:15" },
                { "day": 4, "date": "2025-06-18", "weekday": "Tuesday",   "sleepStartTime": "23:55", "wakeUpTime": "06:55" },
                { "day": 5, "date": "2025-06-19", "weekday": "Wednesday", "sleepStartTime": "00:20", "wakeUpTime": "07:20" },
                { "day": 6, "date": "2025-06-20", "weekday": "Thursday",  "sleepStartTime": "00:10", "wakeUpTime": "07:10" },
                { "day": 7, "date": "2025-06-21", "weekday": "Friday",    "sleepStartTime": "00:00", "wakeUpTime": "07:00" }
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
                  { "id": 1,  "date": "2025-06-20", "title": "일기 제목 1" },
                  { "id": 2,  "date": "2025-06-21", "title": "일기 제목 2" },
                  { "id": 3,  "date": "2025-06-22", "title": "일기 제목 3" },
                  { "id": 4,  "date": "2025-06-23", "title": "일기 제목 4" },
                  { "id": 5,  "date": "2025-06-24", "title": "일기 제목 5" },
                  { "id": 6,  "date": "2025-06-25", "title": "일기 제목 6" },
                  { "id": 7,  "date": "2025-06-26", "title": "일기 제목 7" },
                  { "id": 8,  "date": "2025-06-27", "title": "일기 제목 8" },
                  { "id": 9,  "date": "2025-06-28", "title": "일기 제목 9" },
                  { "id": 10, "date": "2025-06-29", "title": "일기 제목 10" }
                ]
              }
            }
            """

        case .waste:
            json = """
            {
              "isSuccess": true,
              "code": 200,
              "message": "휴지통 일기 목록 조회 성공",
              "result": {
                "diaries": [
                  { "id": 1,  "date": "2025-06-20", "title": "일기 제목 1" },
                  { "id": 2,  "date": "2025-06-21", "title": "일기 제목 2" },
                  { "id": 3,  "date": "2025-06-22", "title": "일기 제목 3" },
                  { "id": 4,  "date": "2025-06-23", "title": "일기 제목 4" },
                  { "id": 5,  "date": "2025-06-24", "title": "일기 제목 5" },
                  { "id": 6,  "date": "2025-06-25", "title": "일기 제목 6" },
                  { "id": 7,  "date": "2025-06-26", "title": "일기 제목 7" },
                  { "id": 8,  "date": "2025-06-27", "title": "일기 제목 8" },
                  { "id": 9,  "date": "2025-06-28", "title": "일기 제목 9" },
                  { "id": 10, "date": "2025-06-29", "title": "일기 제목 10" }
                ]
              }
            }
            """

        case .wastePatch:
            json = """
            {
              "isSuccess": true,
              "code": 200,
              "message": "일기 삭제 성공"
            }
            """
            
        case .deleteDiary:
            json = """
            {
              "isSuccess": true,
              "code": 200,
              "message": "일기 영구 삭제 성공"
            }
            """
            
        case .patchProfile(let memberId, let name, let profileImgUrl, let gender, let birth):
                if name.lowercased() == "duplicate" {
                    // 실패 케이스: 닉네임 중복
                    json = """
                    {
                      "code": 409,
                      "message": "이미 사용 중인 닉네임입니다.",
                      "data": null
                    }
                    """
                } else {
                    // 성공 케이스
                    json = """
                    {
                      "code": 200,
                      "message": "프로필 수정 성공",
                      "data": {
                        "memberId": "\(memberId.uuidString)",
                        "name": "\(name)",
                        "profileImgUrl": "\(profileImgUrl)",
                        "gender": "\(gender)",
                        "birth": "\(birth)"
                      }
                    }
                    """
                }
        }
        return Data(json.utf8)
    }
}
