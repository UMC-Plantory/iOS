//
//  AuthRouter.swift
//  Plantory
//
//  Created by 주민영 on 7/30/25.
//

import Foundation
import Moya

enum AuthRouter {
    case kakaoLogin(idToken: KakaoUser) // 카카오 로그인
    case sendRefreshToken(refreshToken: String) // 리프레시 토큰 갱신
}

extension AuthRouter: APITargetType {
    var baseURL: URL {
        return URL(string: "\(Config.baseUrl)")!
    }
    
    var path: String {
        switch self {
        case .kakaoLogin:
            return "/member/kko/login"
        case .sendRefreshToken:
            return "/token/refresh"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .kakaoLogin(let idToken):
            return .requestJSONEncodable(idToken)
        case .sendRefreshToken(let refrshToken):
            return .requestJSONEncodable(refrshToken)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
