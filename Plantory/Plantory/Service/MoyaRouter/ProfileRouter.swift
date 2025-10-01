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
    /// 임시보관함 → 휴지통
    case wastePatch(diaryIds: [Int])
    
    // 휴지통
    case waste(sort: String)
    /// 휴지통 → 영구삭제
    case deleteDiary(diaryIds: [Int])
    /// 휴지통 → 임시보관함(복원)
    case restore(diaryIds: [Int])
    
    //단일 일기 데이터 조회
    case fetchDiary(id: Int)
    
    // 스크랩
    case scrap(sort: String, cursor: String?)
    
    // 상세 마이프로필
    case patchProfile(nickname: String, userCustomId: String, gender: String, birth: String, profileImgUrl: String,deleteProfileImg: Bool)
    case myProfile
    case withdrawAccount
    
    // 전체 마이페이지
    case profileStats
    case logout
}

extension ProfileRouter {
    var baseURL: URL {
        URL(string: "https://plantory-api.site/v1/plantory")!
    }

    var path: String {
        switch self {
        // 수면 통계
        case .weeklyStats:            return "/statistics/sleep/weekly"
        case .monthlyStats:           return "/statistics/sleep/monthly"
        // 감정 통계
        case .weeklyEmotionStats:     return "/statistics/emotion/weekly"
        case .monthlyEmotionStats:    return "/statistics/emotion/monthly"
        // 임시보관함
        case .temporary, .restore:              return "/diaries/temp-status"
        // 휴지통으로 이동(임시→휴지통)
        case .wastePatch, .waste:             return "/diaries/waste-status"
        // 영구삭제
        case .deleteDiary:            return "/diaries"
        // 스크랩
        case .scrap:                    return "/diaries/scrap-status"
        // 단일 일기 조회
        case .fetchDiary(let id):
            return "/diaries/\(id)"
            
        // 마이프로필
        case .myProfile: return "/members/myprofile"
            
        // 마이프로필
        case .patchProfile, .profileStats: return "/members/profile"
        case .withdrawAccount: return "/members"
            
        // 전체 마이페이지
        case .logout: return "/members/auth"
        }
    }

    var method: Moya.Method {
        switch self {
        case .wastePatch, .restore, .patchProfile, .withdrawAccount:
            return .patch

        case .deleteDiary, .logout:
            return .delete
            
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        // GET: today 쿼리
        case .weeklyStats(let today),
             .monthlyStats(let today),
             .weeklyEmotionStats(let today),
             .monthlyEmotionStats(let today):
            return .requestParameters(
                parameters: ["today": today],
                encoding: URLEncoding.default
            )

        // GET: sort 쿼리
        case .temporary(let sort),
             .waste(let sort):
            return .requestParameters(
                parameters: ["sort": sort],
                encoding: URLEncoding.default
            )

        // 마이프로필
        case .myProfile, .withdrawAccount, .logout:
            return .requestPlain

        // PATCH: 임시→휴지통 (JSON body)
        case .wastePatch(let diaryIds):
            return .requestParameters(
                parameters: ["diaryIds": diaryIds],
                encoding: JSONEncoding.default
            )

        // PATCH: 휴지통→임시 (복원, JSON body)
        case .restore(let diaryIds):
            return .requestParameters(
                parameters: ["diaryIds": diaryIds],
                encoding: JSONEncoding.default
            )
        
        // 스크랩
        case .scrap(let sort, let cursor):
            if let cursor = cursor {
                return .requestParameters(
                    parameters: ["sort": sort, "cursor": cursor],
                    encoding: URLEncoding.default
                )
            }
            return .requestParameters(
                parameters: ["sort": sort],
                encoding: URLEncoding.default
            )

        // DELETE: 영구삭제 (JSON body 허용 스펙)
        case .deleteDiary(let diaryIds):
            return .requestParameters(
                parameters: ["diaryIds": diaryIds],
                encoding: JSONEncoding.default
            )
            
        // GET: 단일 일기 조회
        case .fetchDiary:
            return .requestPlain

        // PATCH: 프로필 수정 (JSON body)
        case .patchProfile(let nickname, let userCustomId, let gender, let birth, let profileImgUrl, let deleteProfileImg):
            return .requestParameters(
                parameters: [
                    "nickname":      nickname,
                    "userCustomId":  userCustomId,
                    "gender":        gender,
                    "birth":         birth,
                    "profileImgUrl": profileImgUrl,
                    "deleteProfileImg": deleteProfileImg
                ],
                encoding: JSONEncoding.default
            )
            
        // 전체 마이페이지
        case .profileStats:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var sampleData: Data {
        let json: String
        switch self {
        case .weeklyStats:
            json = """
            { "startDate":"2025-06-15","endDate":"2025-06-21","todayWeekday":"Saturday","averageSleepMinutes":697,"dailySleepRecords":[] }
            """
        case .monthlyStats:
            json = """
            { "startDate":"2025-06-01","endDate":"2025-06-30","todayWeekday":"Monday","averageSleepMinutes":444,"weeklySleepRecords":[] }
            """
        case .weeklyEmotionStats:
            json = """
            { "startDate":"2025-07-05","endDate":"2025-07-11","todayWeekday":"monday","mostFrequentEmotion":"joy","emotionFrequency":{} }
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
                "emotionFrequency": { "HAPPY": 11, "AMAZING": 4, "SAD": 7, "ANGRY": 2, "SOSO": 5, "DEFAULT": 0 }
              }
            }
            """
        case .temporary:
            json = """
            { "isSuccess": true, "code": 200, "message": "임시보관 목록 조회 성공", "result": { "diaries": [] } }
            """
        case .waste:
            json = """
            { "isSuccess": true, "code": 200, "message": "휴지통 목록 조회 성공", "result": { "diaries": [] } }
            """
        case .wastePatch:
            json = """
            { "isSuccess": true, "code": "COMMON200", "message": "일기 휴지통 이동 성공" }
            """
        case .restore:
            json = """
            { "isSuccess": true, "code": "COMMON200", "message": "일기 복원 성공" }
            """
        case .deleteDiary:
            json = """
            { "isSuccess": true, "code": "COMMON200", "message": "일기 영구 삭제 성공" }
            """
        case .scrap:
            json = """
            {
                "isSuccess": true,
                "code": "COMMON200",
                "message": "성공입니다.",
                "result": {
                    "diaries": [
                      {
                        "diaryId": 1,
                        "diaryDate": "2025-06-20",
                        "title": "일기 제목 1",
                        "status": "SCRAP",
                        "emotion": "HAPPY",
                        "content": "일기 내용"
                    },
                    {
                        "diaryId": 2,
                        "diaryDate": "2025-06-21",
                        "title": "일기 제목 2",
                        "status": "SCRAP",
                        "emotion": "SAD",
                        "content": "일기 내용"
                    }
                ],
                "hasNext": true,
                "nextCursor": “2025-06-21”
               }
            }
            """
            
        case .fetchDiary:
            // 단일 일기 조회
            json = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "성공입니다.",
              "result": {
                "diaryId": 1,
                "diaryDate": "2025-06-20"
                "emotion": "HAPPY",
                "title": "일기 제목1",
                "content": "오늘은…",
                "diaryImgUrl": "https…",
                "status": "NORMAL"
              }
            }
            """
            
        case .myProfile:
            json = """
            { "code": 200, "message": "프로필 조회 성공",
              "data": { "memberId":"123E4567-E89B-12D3-A456-426614174000","name":"손가영","email":"user@email.com","gender":"female","birth":"2004-03-15","profileImgUrl":"https://...", "wateringCanCnt":5,"continuousRecordCnt":3,"totalRecordCnt":10,"avgSleepTime":"07:30","totalBloomCnt":2,"status":"ACTIVE" } }
            """
        case .patchProfile(nickname: _, userCustomId: _, gender: _, birth: _, profileImgUrl: _, deleteProfileImg: _):
            json = """
                
                """
        case .profileStats:
                    json = """
                    {
                      "userCustomId": "songe2",
                      "nickname": "송이",
                      "profileImgUrl": "https://...",
                      "continuousRecordCnt": 35,
                      "totalRecordCnt": 5,
                      "avgSleepTime": 413,   // 분
                      "totalBloomCnt": 4
                    }
                    """
        case .withdrawAccount:
            json = """
                
                """
        case .logout:
            json = """
                
                """
        }
        return Data(json.utf8)
    }
}
