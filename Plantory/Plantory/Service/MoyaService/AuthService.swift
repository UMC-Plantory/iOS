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

/// 인증 서비스 프로토콜
protocol AuthServiceProtocol {
    
    /// 카카오 로그인 요청
    func kakaoLogin(idToken: KakaoUser) -> AnyPublisher<LoginResponse, APIError>
    
    /// 애플 로그인 요청
    func appleLogin(request: AppleUser) -> AnyPublisher<LoginResponse, APIError>
    
    /// 약관 동의
    func postAgreements(request: AgreementsRequest) -> AnyPublisher<AgreementsResponse, APIError>
    
    /// 회원가입 완료
    func patchSignup(request: SignupRequest) -> AnyPublisher<SignupResponse, APIError>
}

/// Auth API를 사용하는 서비스
final class AuthService: AuthServiceProtocol {
    
    /// MoyaProvider를 통해 API 요청을 전송
    let provider: MoyaProvider<AuthRouter>
    let noTokenProvider: MoyaProvider<AuthRouter>
    
    // MARK: - Initializer
    
    /// 기본 initializer - verbose 로그 플러그인을 포함한 provider 생성
    init(provider: MoyaProvider<AuthRouter> = APIManager.shared.createProvider(for: AuthRouter.self), noTokenProvider: MoyaProvider<AuthRouter> = APIManager.shared.createNoAuthProvider(for: AuthRouter.self)) {
        self.provider = provider
        self.noTokenProvider = noTokenProvider
    }
    
    // MARK: - 카카오 로그인 요청
    
    /// 로그인 요청
    /// - Parameter idToken: 로그인 요청 모델
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func kakaoLogin(idToken: KakaoUser) -> AnyPublisher<LoginResponse, APIError> {
        return provider.requestResult(.kakaoLogin(idToken: idToken), type: LoginResponse.self)
    }
    
    // MARK: - 애플 로그인 요청
    
    /// 로그인 요청
    /// - Parameter identityToken: 로그인 요청 모델
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func appleLogin(request: AppleUser) -> AnyPublisher<LoginResponse, APIError> {
        return provider.requestResult(.appleLogin(request: request), type: LoginResponse.self)
    }
    
    // MARK: - 약관 동의
    
    /// 약관 동의
    /// - Parameter request: 약관 동의 요청 모델
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func postAgreements(request: AgreementsRequest) -> AnyPublisher<AgreementsResponse, APIError> {
        return provider.requestResult(.postAgreements(request: request), type: AgreementsResponse.self)
    }
    
    // MARK: - 회원가입 완료
    
    /// 회원가입 완료
    /// - Parameter request: 회원가입 완료 요청 모델
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func patchSignup(request: SignupRequest) -> AnyPublisher<SignupResponse, APIError> {
        return provider.requestResult(.patchSignup(request: request), type: SignupResponse.self)
    }
}
