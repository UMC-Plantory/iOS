//
//  AppleLoginManager.swift
//  Plantory
//
//  Created by 주민영 on 8/8/25.
//

import Foundation
import AuthenticationServices

/// 애플 로그인 매니저 (async/await 기반)
/// - Apple 로그인 요청을 시작하고 결과를 async로 반환하는 싱글톤 클래스
final class AppleLoginManager: NSObject {
    
    /// 전역에서 공유되는 싱글톤 인스턴스
    static let shared = AppleLoginManager()
    
    /// 로그인 결과를 비동기적으로 전달하기 위한 continuation
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
    
    /// 로그인 팝업이 표시될 기준 윈도우(anchor)
    private var anchor: ASPresentationAnchor?
    
    /// Apple 로그인 시작 (async/await 기반)
    /// - Parameter presentationAnchor: 로그인 UI를 띄울 기준이 되는 window
    /// - Returns: Apple 로그인 성공 시의 credential (userID, token 등 포함)
    func startSignInWithAppleFlow(presentationAnchor: ASPresentationAnchor) async throws -> ASAuthorizationAppleIDCredential {
        self.anchor = presentationAnchor
        
        // Apple 로그인 흐름을 비동기적으로 처리
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            // Apple 로그인 요청 생성
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.email, .fullName] // 사용자로부터 받을 정보
            
            // 인증 컨트롤러 설정
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self // 결과 처리를 위한 delegate 설정
            controller.presentationContextProvider = self // 로그인 창 위치 제공
            controller.performRequests() // 로그인 요청 실행
        }
    }
}

// MARK: - 로그인 결과 처리 델리게이트

extension AppleLoginManager: ASAuthorizationControllerDelegate {
    
    /// Apple 로그인 성공 시 호출되는 delegate 메서드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 성공적으로 credential을 전달하고 flow 종료
            continuation?.resume(returning: credential)
        } else {
            // credential이 예상과 다를 경우 에러로 처리
            continuation?.resume(throwing: NSError(domain: "InvalidCredential", code: -1))
        }
        continuation = nil
    }
    
    /// Apple 로그인 실패 시 호출되는 delegate 메서드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 실패 사유를 에러로 반환하고 flow 종료
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - 로그인 UI 위치 제공

extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {
    
    /// Apple 로그인 UI를 띄울 위치(Window)를 제공
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // anchor가 설정되어 있다면 사용, 아니면 빈 UIWindow 반환
        return anchor ?? UIWindow()
    }
}
