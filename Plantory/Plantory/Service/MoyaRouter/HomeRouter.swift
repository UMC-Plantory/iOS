//
//  HomeRouter.swift
//  Plantory
//
//  Created by 김지우 on 8/12/25.
//

import Foundation
import Moya

enum HomeRouter {
    /// 홈 월간 데이터 조회 (yearMonth 미입력 시 이번 년도/달 자동 조회)
    case getHomeMonthly(yearMonth: String?)
    /// 특정 날짜 일기 요약 조회
    case getHomeDiary(date: String)
}

extension HomeRouter: APITargetType {

    
    var baseURL: URL {
        return URL(string: Config.baseUrl)!   // 굳이 문자열 인터폴레이션 불필요
    }

    
    var path: String {
        switch self {
        case .getHomeMonthly:
            return "/home"
        case .getHomeDiary:
            return "/diaries/date"   // 스펙에 맞게 유지
        }
    }

    
    var method: Moya.Method {
        switch self {
        case .getHomeMonthly, .getHomeDiary:
            return .get
        }
    }

    
    var task: Task {
        switch self {
        case .getHomeMonthly(let yearMonth):
            var params: [String: Any] = [:]
            if let ym = yearMonth, !ym.isEmpty {
                params["yearMonth"] = ym
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .getHomeDiary(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
        }
    }

    
    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }

    
    var sampleData: Data {
        let json: String
        switch self {
        case .getHomeMonthly:
            json = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "성공입니다.",
              "result": {
                "yearMonth": "2025-08",
                "wateringProgress": 0,
                "continuousRecordCnt": 0,
                "diaryDates": [
                  { "date": "2025-08-12", "emotion": "HAPPY" },
                  { "date": "2025-08-13", "emotion": "SAD" }
                ]
              }
            }
            """

        case .getHomeDiary:
            json = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "성공입니다.",
              "result": {
                "diaryId": 1,
                "diaryDate": "2025-08-12",
                "emotion": "HAPPY",
                "title": "산책하기 좋은 날"
              }
            }
            """
        }
        return Data(json.utf8)
    }
}
