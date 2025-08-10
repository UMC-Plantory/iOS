//
//  KakakoLoginManager.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

class KakakoLoginManager {
    
    let keychainManager = KeychainService.shared
    
    @MainActor
    public func login() async throws -> KakaoUser {
        let token: OAuthToken
        
        if UserApi.isKakaoTalkLoginAvailable() {
            do {
                token = try await loginWithKakaoApp()
            } catch {
                throw KakaoLoginError.failedToLoginWithKakaoApp
            }
        } else {
            do {
                token = try await loginWithKakaoWeb()
            } catch {
                throw KakaoLoginError.failedToLoginWithKakaoWeb
            }
        }
        
        return try await getIDToken(token: token)
    }
    
    @MainActor
    private func loginWithKakaoApp() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let token = token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: KakaoLoginError.failedToLoginWithKakaoApp)
                }
            }
        }
    }
    
    @MainActor
    private func loginWithKakaoWeb() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let token = token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: KakaoLoginError.failedToLoginWithKakaoWeb)
                }
            }
        }
    }
    
    private func getIDToken(token: OAuthToken) async throws -> KakaoUser {
        guard let idToken = token.idToken else {
            throw KakaoLoginError.failedToFetchIDToken
        }
        return KakaoUser(idToken: idToken)
    }
}
