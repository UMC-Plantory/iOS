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
    case appleLogin(request: AppleUser) // 애플 로그인
    case sendRefreshToken(refreshToken: String) // 리프레시 토큰 갱신
    
    case postAgreements(request: AgreementsRequest) // 약관 동의
    case patchSignup(request: SignupRequest) // 회원 가입 완료
}

extension AuthRouter: APITargetType {
    var baseURL: URL {
        switch self {
        default:
            return URL(string: "\(Config.baseUrl)")!
        }
    }
    
    var path: String {
        switch self {
        case .kakaoLogin:
            return "/members/auth/kko"
        case .appleLogin:
            return "/members/auth/apple"
        case .sendRefreshToken:
            return "/auth/refresh"
        case .postAgreements:
            return "members/agreements"
        case .patchSignup:
            return "members/signup"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .patchSignup, .appleLogin:
            return .patch
        default:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .kakaoLogin(let idToken):
            return .requestJSONEncodable(idToken)
        case .appleLogin(let request):
            return .requestJSONEncodable(request)
        case .sendRefreshToken(let refrshToken):
            return .requestJSONEncodable(refrshToken)
        case .postAgreements(let request):
            return .requestJSONEncodable(request)
        case .patchSignup(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
