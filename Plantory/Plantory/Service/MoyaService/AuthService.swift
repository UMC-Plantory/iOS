//
//  AuthService.swift
//  Plantory
//
//  Created by 주민영 on 8/4/25.
//

import Foundation
import CombineMoya
import Moya
import Combine

/// 채팅 서비스 프로토콜
protocol AuthServiceProtocol {
    
    // 로그인 요청
    func kakaoLogin(idToken: KakaoUser) -> AnyPublisher<LoginResponse, APIError>
}

/// Chat API를 사용하는 서비스
final class AuthService: AuthServiceProtocol {
    
    /// MoyaProvider를 통해 API 요청을 전송
    let provider: MoyaProvider<AuthRouter>
    
    // MARK: - Initializer
    
    /// 기본 initializer - verbose 로그 플러그인을 포함한 provider 생성
    init(provider: MoyaProvider<AuthRouter> = APIManager.shared.createProvider(for: AuthRouter.self)) {
        self.provider = provider
    }
    
    // MARK: - 로그인 요청
    
    /// 로그인 요청
    /// - Parameter request: 채팅 요청 모델
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func kakaoLogin(idToken: KakaoUser) -> AnyPublisher<LoginResponse, APIError> {
        return provider.requestResult(.kakaoLogin(idToken: idToken), type: LoginResponse.self)
    }
}
