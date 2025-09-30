// AddDiaryRouter.swift

import Foundation
import Moya

enum AddDiaryRouter: APITargetType {
    case create(body: AddDiaryRequest)
    case checkExist(date: String)           // GET /diaries/exist?date=yyyy-MM-dd
    case getTemp(date: String)             // GET /diaries/temp?date=yyyy-MM-dd
    case checkTempExist(date: String)          // TEMP 존재 여부

}

extension AddDiaryRouter {
    var baseURL: URL { URL(string: "\(Config.baseUrl)")! }

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
        case .checkExist(let date),
            .getTemp(let date),
            .checkTempExist(let date):
        return .requestParameters(parameters: ["date": date],
                                  encoding: URLEncoding.queryString)
            }
        }

    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }

    var sampleData: Data {
        switch self {
        case .create:
            return Data("""
            {"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"diaryId":1,"diaryDate":"2025-06-20","emotion":"HAPPY","title":"일기 제목1","content":"오늘은…","diaryImgUrl":"https…","status":"NORMAL"}}
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
