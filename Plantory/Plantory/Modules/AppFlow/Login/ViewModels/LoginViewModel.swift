//
//  LoginViewModel.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Combine
import AuthenticationServices
import SwiftUI

/// 로그인 화면에서 사용되는 ViewModel
/// 사용자 ID/비밀번호 로그인 및 카카오 로그인 기능을 제공하며, 키체인과 앱 흐름 전환을 관리함
@Observable
class LoginViewModel {
    
    // MARK: - Toast
    
    var toast: CustomToast? = nil
    
    // MARK: - 로딩
    
    var isLoading = false
    
    // MARK: - 의존성 주입 및 비동기 처리
    
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()
    
    /// 자동 로그인 관리
    let sessionManager: SessionManager
    
    /// 로그인 화면전환 관리
    let loginRouter: LoginRouter
    
    // MARK: - Init
        
    /// ViewModel 초기화
    /// - Parameters:
    ///   - container: DIContainer를 주입받아 서비스 사용
    ///   - sessionManager: SessionManager를 주입받아 사용
    init(container: DIContainer, sessionManager: SessionManager, loginRouter: LoginRouter) {
        self.container = container
        self.sessionManager = sessionManager
        self.loginRouter = loginRouter
    }
    
    // MARK: - ManagerProperty
        
    let keychainManager = KeychainService.shared
    
    // MARK: - Kakao Login
    
    /// 카카오 로그인 처리 함수
    /// 카카오 SDK를 통해 로그인 후 토큰 및 사용자 정보를 키체인에 저장하고 앱 상태 전환
    @MainActor
    public func kakaoLogin() async {
        do {
            let kakaoUser = try await container.useCaseService.kakaoManager.login()
            
            // 서버에 로그인 요청
            try await sendKakaoLoginToServer(idToken: kakaoUser)
        } catch {
            if let kakaoError = error as? KakaoLoginError {
                print("카카오 에러메시지:", kakaoError.localizedDescription)
            } else {
                print("에러 메시지:", error.localizedDescription)
            }
        }
    }
    
    /// 카카오 로그인 API 호출
    @MainActor
    private func sendKakaoLoginToServer(idToken: KakaoUser) async throws {
        self.isLoading = true

        // Keychain에 저장된 FCM 토큰 읽기
        let fcm = keychainManager.loadFCMToken()
        var request = idToken
        request.fcmToken = fcm

        container.useCaseService.authService.kakaoLogin(idToken: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "로그인 오류",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("로그인 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                let tokenInfo = TokenInfo(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                /// 받은 토큰을 키체인에 저장
                self?.keychainManager.saveToken(tokenInfo)
                self?.routeAfterLogin(status: response.memberStatus)
                
                if (response.memberStatus == .active) {
                    self?.sessionManager.login()
                }
                
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Apple Login
    
    /// 애플 로그인 처리 함수
    @MainActor
    public func appleLogin(presentationAnchor: ASPresentationAnchor) async {
        do {
            let credential = try await container.useCaseService.appleManager.startSignInWithAppleFlow(presentationAnchor: presentationAnchor)
            try await handleLoginSuccess(credential: credential)
        } catch {
            print("애플 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    /// 로그인 성공 후 처리
    private func handleLoginSuccess(credential: ASAuthorizationAppleIDCredential) async throws {
        // identityToken, authorizationCode 추출
        guard let identityToken = credential.identityToken,
              let authorizationCode = credential.authorizationCode,
              let identityTokenString = String(data: identityToken, encoding: .utf8),
        let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
            throw NSError(domain: "AppleTokenError", code: -2)
        }
        
        // 서버에 로그인 요청
        try await sendAppleLoginToServer(
            identityToken: identityTokenString,
            authorizationCode: authorizationCodeString
        )
    }
    
    /// 애플 로그인 API 호출
    @MainActor
    private func sendAppleLoginToServer(
        identityToken: String,
        authorizationCode: String
    ) async throws {
        self.isLoading = true
        
        // Keychain에 저장된 FCM 토큰 읽기
        let fcm = keychainManager.loadFCMToken()
        let request = AppleUser(
            identityToken: identityToken,
            fcmToken: fcm,
            authorizationCode: authorizationCode
        )

        container.useCaseService.authService.appleLogin(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "로그인 오류",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("로그인 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                let tokenInfo = TokenInfo(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                /// 받은 토큰을 키체인에 저장
                self?.keychainManager.saveToken(tokenInfo)
                self?.routeAfterLogin(status: response.memberStatus)
                
                if (response.memberStatus == .active) {
                    self?.sessionManager.login()
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    // MARK: - private func
    
    @MainActor
    private func routeAfterLogin(status: MemberStatus) {
        switch status {
        case .pending, .inActive:
            loginRouter.push(.permit)
        case .agree:
            loginRouter.push(.profileInfo)
        case .active:
            break
        }
    }
}

