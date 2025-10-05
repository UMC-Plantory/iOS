//
//  AddDiaryRouter.swift
//  Plantory
//
//  Created by 김지우 on 10/6/25.
//


import Foundation
import Moya

enum AddDiaryRouter: APITargetType {
    case create(body: AddDiaryRequest)        // POST /diaries
    case fetchDiaryStatus(date: String)       // GET /diaries/temp-status/exists?date=2025-10-06
}

extension AddDiaryRouter {
    var baseURL: URL { URL(string: Config.baseUrl)! }

    var path: String {
        switch self {
        case .create:
            return "/diaries"
        case .fetchDiaryStatus:
            return "/diaries/temp-status/exists"
        }
    }

    var method: Moya.Method {
        switch self {
        case .create:
            return .post
        case .fetchDiaryStatus:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .create(let body):
            return .requestJSONEncodable(body)

        case .fetchDiaryStatus(let date):
            // 쿼리 파라미터로 date를 전달
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
        }
    }

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

        case .fetchDiaryStatus:
            return Data("""
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "성공입니다.",
              "result": {
                "isExist": true
              }
            }
            """.utf8)
        }
    }
}
