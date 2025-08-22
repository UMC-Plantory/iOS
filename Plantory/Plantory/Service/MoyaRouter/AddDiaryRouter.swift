//
//  AddDiaryRouter.swift
//  Plantory
//
//  Created by 주민영 on 8/15/25.
//

import Foundation
import Moya

/// 새 일기 등록 라우터
enum AddDiaryRouter: APITargetType {
    case create(body: AddDiaryRequest)
}

extension AddDiaryRouter {
    /// 기본 URL
    var baseURL: URL {
        return URL(string: "\(Config.baseUrl)")!
    }

    /// 경로
    var path: String {
        switch self {
        case .create:
            return "/diaries"
        }
    }

    /// HTTP 메서드
    var method: Moya.Method {
        switch self {
        case .create: return .post
        }
    }

    /// Task (파라미터/인코딩)
    var task: Task {
        switch self {
        case .create(let body):
            return .requestJSONEncodable(body)
        }
    }

    /// 헤더
    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }

    /// 샘플 데이터
    var sampleData: Data {
        switch self {
        case .create:
            let json = """
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
                "status": “NORMAL”
              }
            }
            """
            return Data(json.utf8)
        }
    }
}
