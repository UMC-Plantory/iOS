//
//  TerrariumAPI.swift
//  Plantory
//
//  Created by 박정환 on 7/25/25.
//
    
import Moya
import Foundation

enum TerrariumRouter {
    case getTerrarium(memberId: Int)
    case water(terrariumId: Int, memberId: Int)
    case getMonthlyTerrarium(memberId: Int, month: String)
    case getTerrariumDetail(terrariumId: Int)
}

extension TerrariumRouter: APITargetType {
    var baseURL: URL {
        return URL(string: "\(Config.baseUrl)")!
    }
    
    var path: String {
        switch self {
        case .getTerrarium:
            return "/terrariums"
        case .water(let terrariumId, _):
            return "/terrariums/\(terrariumId)/watering"
        case .getMonthlyTerrarium:
            return "/terrariums/monthly"
        case .getTerrariumDetail(let terrariumId):
            return "/terrariums/\(terrariumId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTerrarium, .getMonthlyTerrarium:
            return .get
        case .water:
            return .post
        case .getTerrariumDetail:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getTerrarium:
            return .requestPlain
        case .water(_, let memberId):
            return .requestParameters(
                parameters: ["memberId": memberId],
                encoding: JSONEncoding.default
            )
        case .getMonthlyTerrarium(let memberId, let month):
            return .requestParameters(
                parameters: [
                    "memberId": memberId,
                    "date": month
                ],
                encoding: URLEncoding.queryString
            )
        case .getTerrariumDetail:
            return .requestPlain
        }
    }
    
    var headers: [String:String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
        case .getTerrarium:
            return """
                { "isSuccess": true, "code": "OK", "message": "ok",
                  "result": { "terrariumId": 1, "flowerImgUrl": "https://...", "terrariumWateringCount": 3, "memberWateringCount": 1 }
                }
                """.data(using: .utf8)!
        case .water:
            return """
                { "isSuccess": true, "code": "OK", "message": "ok",
                  "result": { "terrariumId": 1, "flowerImgUrl": "https://...", "terrariumWateringCount": 4, "memberWateringCount": 2 }
                }
                """.data(using: .utf8)!
        case .getMonthlyTerrarium:
            return """
                { "isSuccess": true, "code": "OK", "message": "ok",
                  "result": [
                    { "terrariumId": 1, "nickname": "토리", "bloomAt": "2025-08-11T09:34:28.000Z", "flowerImgUrl": "https://...", "flowerName": "해바라기" }
                  ]
                }
                """.data(using: .utf8)!
        case .getTerrariumDetail:
            return """
                { "isSuccess": true, "code": "COMMON200", "message": "성공입니다.",
                  "result": {
                    "startAt": "2025-07-31T16:00:00",
                    "bloomAt": "2025-08-03T17:45:07.086812",
                    "mostEmotion": "HAPPY",
                    "usedDiaries": ["2024-06-01","2024-06-02","2024-06-03"],
                    "firstStepDate": "2025-07-31",
                    "secondStepDate": "2025-08-03",
                    "thirdStepDate": "2025-08-03"
                  }
                }
            """.data(using: .utf8)!
        }
    }
}
