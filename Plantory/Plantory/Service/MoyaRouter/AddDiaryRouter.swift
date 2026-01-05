//
//  AddDiaryRouter.swift
//  Plantory
//
//  Created by 김지우 on 10/6/25.
//


import Foundation
import Moya

enum AddDiaryRouter: APITargetType {
    // 일기 생성 (NORMAL 또는 TEMP)
    case create(body: AddDiaryRequest)
    // 정식 저장 일기 존재 여부 조회
    case fetchNormalDiaryStatus(date: String)
    // 임시 저장 일기 존재 여부 조회
    case fetchTempDiaryStatus(date: String)
    // 임시 저장된 일기 실제 데이터 불러오기
    case fetchTempDiary(id:Int)
}

extension AddDiaryRouter {
    var baseURL: URL { URL(string: Config.baseUrl)! }
    
    var path: String {
        switch self {
       
        case .create:
            return "/diaries"

        case .fetchNormalDiaryStatus:
            return "/diaries/normal-status/exists"

        case .fetchTempDiaryStatus:
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
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )

        case .fetchTempDiaryStatus(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )

        case .fetchTempDiary(let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString )
        }
        
        var headers: [String: String]? {
               switch self {
               case .create:
                   return ["Content-Type": "application/json"]
               default:
                   return nil     // Token은 APIManager에서 자동 주입
               }
           }

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
                
            case .fetchTempDiaryStatus:
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
            """.utf8)
                
                
                
            }
        }
    }
}
