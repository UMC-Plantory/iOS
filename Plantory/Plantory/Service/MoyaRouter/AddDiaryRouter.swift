// AddDiaryRouter.swift

import Foundation
import Moya

enum AddDiaryRouter: APITargetType {
    case create(body: AddDiaryRequest)               // POST /diaries
    case checkExist(diaryDate: String)               // GET  /diaries/exist?diaryDate=yyyy-MM-dd
    case getTemp(diaryDate: String)                  // GET  /diaries/temp?diaryDate=yyyy-MM-dd
    case checkTempExist(diaryDate: String)           // GET  /diaries/temp/exist?diaryDate=yyyy-MM-dd
}

extension AddDiaryRouter {
    var baseURL: URL { URL(string: Config.baseUrl)! }

    var path: String {
        switch self {
        case .create:               return "/diaries"
        case .checkExist:           return "/diaries/exist"
        case .getTemp:              return "/diaries/temp"
        case .checkTempExist:       return "/diaries/temp/exist"
        }
    }

    var method: Moya.Method {
        switch self {
        case .create:               return .post
        case .checkExist, .getTemp, .checkTempExist:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .create(let body):
            return .requestJSONEncodable(body)

        case .checkExist(let diaryDate),
             .getTemp(let diaryDate),
             .checkTempExist(let diaryDate):
            // 명세/DTO와 일관되게 'diaryDate' 키 사용
            return .requestParameters(
                parameters: ["diaryDate": diaryDate],
                encoding: URLEncoding.queryString
            )
        }
    }

    // APITargetType에서 Content-Type을 공통으로 처리하므로 생략 가능
    var headers: [String : String]? { nil }

    var sampleData: Data {
        switch self {
        case .create:
            return Data("""
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "성공입니다.",
              "result": {
                "diaryId": 1,
                "diaryDate": "2025-06-20",
                "emotion": "HAPPY",
                "title": "일기 제목1",
                "content": "오늘은…",
                "diaryImgUrl": "https://…",
                "status": "NORMAL"
              }
            }
            """.utf8)

        case .checkExist:
            return Data(#"{"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"isExist":true}}"#.utf8)

        case .getTemp:
            return Data(#"{"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"diaryDate":"2025-06-20","emotion":"SOSO","content":"임시 내용","sleepStartTime":"2025-06-20T23:00","sleepEndTime":"2025-06-21T07:00","diaryImgUrl":null,"status":"TEMP"}}"#.utf8)

        case .checkTempExist:
            return Data(#"{"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"isExist":false}}"#.utf8)
        }
    }
}
