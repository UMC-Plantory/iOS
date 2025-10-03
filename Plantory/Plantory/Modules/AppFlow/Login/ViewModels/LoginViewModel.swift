//
//  LoginViewModel.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation
import Combine
import AuthenticationServices

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
    
    // MARK: - Init
        
    /// ViewModel 초기화
    /// - Parameters:
    ///   - container: DIContainer를 주입받아 서비스 사용
    ///   - sessionManager: SessionManager를 주입받아 사용
    init(container: DIContainer, sessionManager: SessionManager) {
        self.container = container
        self.sessionManager = sessionManager
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
    private func sendKakaoLoginToServer(idToken: KakaoUser) async throws {
        self.isLoading = true

        container.useCaseService.authService.kakaoLogin(idToken: idToken)
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
                
                Task {
                    await self?.routeAfterLogin(status: response.memberStatus)
                }

                self?.sessionManager.isLoggedIn = response.memberStatus == .active
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
              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            throw NSError(domain: "AppleTokenError", code: -2)
        }
        
        // 서버에 로그인 요청
        try await sendAppleLoginToServer(
            identityToken: identityTokenString
        )
    }
    
    /// 애플 로그인 API 호출
    private func sendAppleLoginToServer(
        identityToken: String
    ) async throws {
        self.isLoading = true
        
        let identityToken = AppleUser(identityToken: identityToken)

        container.useCaseService.authService.appleLogin(identityToken: identityToken)
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
                
                Task {
                    await self?.routeAfterLogin(status: response.memberStatus)
                }
                
                self?.sessionManager.isLoggedIn = response.memberStatus == .active
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    // MARK: - private func
    
    @MainActor
    private func routeAfterLogin(status: MemberStatus) {
        switch status {
        case .pending, .inActive:
            container.navigationRouter.push(.permit)
        case .agree:
            container.navigationRouter.push(.profileInfo)
        case .active:
            break
        }
    }
}
