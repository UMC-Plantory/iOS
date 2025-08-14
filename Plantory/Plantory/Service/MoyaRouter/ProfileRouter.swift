import Moya
import Combine
import Foundation

/// API 라우터 정의
enum ProfileRouter: APITargetType {
    // 수면 통계
    case weeklyStats(today: String)
    case monthlyStats(today: String)
    
    // 감정 통계
    case weeklyEmotionStats(today: String)
    case monthlyEmotionStats(today: String)
    
    // 임시보관함
    case temporary(sort: String)
    //휴지통으로 이동 (임시보관함에 있는 기능)
    case wastePatch(diaryIds: [Int])
    
    // 쓰레기통 조회
    case waste(sort: String)
    // 영구삭제
    case deleteDiary(diaryIds: [Int])
    
    // 상세 마이프로필
    case patchProfile(memberId: UUID, name: String, profileImgUrl: String, gender: String, birth: String)
    case myProfile
}

extension ProfileRouter {
    /// 기본 URL 설정
    var baseURL: URL {
        return URL(string: "https://plantory-api.site/v1/plantory")!
    }

    /// 각 케이스별 요청 경로
    var path: String {
        switch self {
        // 수면 통계
        case .weeklyStats:
            return "/statistics/sleep/weekly"
        case .monthlyStats:
            return "/statistics/sleep/monthly"
            
        // 감정 통계
        case .weeklyEmotionStats:
            return "/statistics/emotion/weekly"
        case .monthlyEmotionStats:       
            return "/statistics/emotion/monthly"

        case .temporary:
            return "/diaries/temp-status"
            
        case .waste, .wastePatch:
            return "/diaries/waste-status"
        case .deleteDiary:
            return "/diary"
            
        // 상세 마이페이지
        case .patchProfile, .myProfile:
            return "/member/myprofile"
        }
    }

    /// HTTP 메서드 설정
    var method: Moya.Method {
        switch self {
        case .myProfile, .weeklyStats, .monthlyStats, .weeklyEmotionStats, .monthlyEmotionStats, .temporary, .waste:
            return .get
            
        case .wastePatch, .patchProfile:
            return .patch
            
        case .deleteDiary:
            return .delete
        }
    }

    /// 요청 Task 설정 (파라미터 인코딩)
    var task: Task {
        switch self {
            
            
        // GET: today 쿼리 파라미터
        case
                .weeklyStats(let today),.monthlyStats(let today),
                .weeklyEmotionStats(let today), .monthlyEmotionStats(let today)  :
            
            return .requestParameters(
                parameters: ["today": today],
                encoding: URLEncoding.default
        )


        // GET: sort 쿼리 파라미터
        case .temporary(let sort), .waste(let sort):
            return .requestParameters(
                parameters: ["sort": sort],
                encoding: URLEncoding.default
            )

        // GET: 상세 마이페이지 조회
        case .myProfile:
            return .requestPlain

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
                    "memberId":      memberId.uuidString,
                    "name":          name,
                    "profileImgUrl": profileImgUrl,
                    "gender":        gender,
                    "birth":         birth
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
              "endDate":   "2025-06-21",
              "todayWeekday": "Saturday",
              "averageSleepMinutes": 697,
              "dailySleepRecords": [
                { "day": 1, "date": "2025-06-15", "weekday": "Sunday",    "sleepStartTime": "20:30", "wakeUpTime": "07:30" },
                { "day": 2, "date": "2025-06-16", "weekday": "Monday",    "sleepStartTime": "23:45", "wakeUpTime": "06:45" },
                { "day": 3, "date": "2025-06-17", "weekday": "Tuesday",   "sleepStartTime": "00:15", "wakeUpTime": "07:15" },
                { "day": 4, "date": "2025-06-18", "weekday": "Wednesday", "sleepStartTime": "15:55", "wakeUpTime": "23:55" },
                { "day": 5, "date": "2025-06-19", "weekday": "Thursday",  "sleepStartTime": "00:20", "wakeUpTime": "07:20" },
                { "day": 6, "date": "2025-06-20", "weekday": "Friday",    "sleepStartTime": "17:10", "wakeUpTime": "07:10" },
                { "day": 7, "date": "2025-06-21", "weekday": "Saturday",  "sleepStartTime": "00:00", "wakeUpTime": "07:00" }
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
                "startDate": "2025-07-05",
                "endDate": "2025-07-11",
                "todayWeekday": "monday",
                "mostFrequentEmotion": "joy",
                "emotionFrequency": {
                    "joy": 3,
                    "surprise": 1,
                    "sadness": 1,
                    "anger": 0,
                    "soso": 1
                }
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
            case .myProfile:
            json = """
            {
              "code": 200,
              "message": "프로필 조회 성공",
              "data": {
                "memberId": "123E4567-E89B-12D3-A456-426614174000",
                "name": "손가영",
                "email": "user@email.com",
                "gender": "female",
                "birth": "2004-03-15",
                "profileImgUrl": "https://...",
                "wateringCanCnt": 5,
                "continuousRecordCnt": 3,
                "totalRecordCnt": 10,
                "avgSleepTime": "07:30",
                "totalBloomCnt": 2,
                "status": "ACTIVE"
              }
            }
            """
        case .monthlyEmotionStats:
            json = """
                {
                  "isSuccess": true,
                  "code": "COMMON200",
                  "message": "성공입니다.",
                  "result": {
                    "startDate": "2025-07-16",
                    "endDate": "2025-08-14",
                    "todayWeekday": "THURSDAY",
                    "mostFrequentEmotion": "HAPPY",
                    "emotionFrequency": {
                      "HAPPY": 11,
                      "AMAZING": 4,
                      "SAD": 7,
                      "ANGRY": 2,
                      "SOSO": 5,
                      "DEFAULT": 0
                    }
                  }
                }
                """
        }
        return Data(json.utf8)
    }
}
