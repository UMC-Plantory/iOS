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
}

extension TerrariumRouter: TargetType {
    var baseURL: URL { URL(string: "http://localhost:9999")! }
    
    var path: String {
        switch self {
        case .getTerrarium:
            return "/terrarium"
        case .water(let terrariumId, _):
            return "/terrarium/\(terrariumId)/water"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTerrarium:
            return .get
        case .water:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getTerrarium(let memberId):
            return .requestParameters(parameters: ["member_id": memberId], encoding: URLEncoding.default)
        case let .water(terrariumId, memberId):
            return .requestParameters(parameters: ["terrarium_id": terrariumId, "member_id": memberId], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return """
        {
          "isSuccess": true,
          "code": "COMMON200",
          "message": "성공입니다.",
          "result": {
            "terrariumId": 1,
            "flowerImgUrl": "https://example.com/rose.jpg",
            "terrariumWateringCount": 2,
            "memberWateringCount": 2
          }
        }
        """.data(using: .utf8)!
    }
}
