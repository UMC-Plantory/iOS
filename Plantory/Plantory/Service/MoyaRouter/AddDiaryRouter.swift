//
//  AddDiaryRouter.swift
//  Plantory
//
//  Created by 김지우 on 10/6/25.
//


import Foundation
import Moya

enum AddDiaryRouter: APITargetType {
    case create(body: AddDiaryRequest)        // 일기 작성
    case fetchNormalDiaryStatus(date: String)  // 해당 날짜에 저장된 일기가 있는지 확인
    case fetchDiaryStatus(date: String)       // 해당 날짜에 임시 저장된 일기가 있는지 확인
    case fetchTempDiary(id:Int)              //임시저장한 일기를 다시 불러옴
}

extension AddDiaryRouter {
    var baseURL: URL { URL(string: Config.baseUrl)! }
    
    var path: String {
        switch self {
        case .create:
            return "/diaries"
        case .fetchNormalDiaryStatus:
            return "/diaries/normal-status/exists"
        case .fetchDiaryStatus:
            return "/diaries/temp-status/exists"
        case .fetchTempDiary:
            return "/diaries/{diary_id}"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .create:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .create(let body):
            return .requestJSONEncodable(body)
            
        case .fetchNormalDiaryStatus(let date):
            // 쿼리 파라미터로 date를 전달
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
            
        case .fetchDiaryStatus(let date):
            // 쿼리 파라미터로 date를 전달
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
        case .fetchTempDiary(let id):
            return .requestParameters(
                parameters: ["diaryId": id],
                encoding: URLEncoding.queryString)
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
                
            case .fetchNormalDiaryStatus:
                return Data("""
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "성공입니다.",
              "result": {
                "exist": true
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
                "exist": true
              }
            }
            """.utf8)
                
            case .fetchTempDiary:
                return Data("""
            {
                "isSuccess": true,
                "code": "COMMON200",
                "message": "일기 수정 성공",
                "result": {
                    "diaryId": 1,
                    "diaryDate": "2025-06-20"
                    "emotion": "HAPPY",
                    "title": "일기 제목1",
                    "content": "오늘은…",
                    "diaryImgUrl": "https…",
                    "status": "NORMAL",
                    }
                }
            """.utf8)
                
                
                
            }
        }
    }
}
