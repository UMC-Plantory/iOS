//
//  LoginViewModel.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation

/// 로그인 화면에서 사용되는 ViewModel
/// 사용자 ID/비밀번호 로그인 및 카카오 로그인 기능을 제공하며, 키체인과 앱 흐름 전환을 관리함
@Observable
class LoginViewModel {
    
    // MARK: - Property
    
    /// 의존성 주입 컨테이너
    var container: DIContainer
    
    // MARK: - Init
        
    /// ViewModel 초기화
    /// - Parameters:
    ///   - container: DIContainer를 주입받아 서비스 사용
    init(container: DIContainer) {
        self.container = container
    }
    
    // MARK: - ManagerProperty
        
    let keychainManager = KeychainService.shared
    
    // MARK: - Login
    
    /// 카카오 로그인 처리 함수
    /// 카카오 SDK를 통해 로그인 후 토큰 및 사용자 정보를 키체인에 저장하고 앱 상태 전환
    @MainActor
    public func kakaoLogin() async {
        do {
            let user = try await container.useCaseService.kakaoManager.login()
            print(user)
            container.navigationRouter.push(.baseTab)
        } catch {
            if let kakaoError = error as? KakaoLoginError {
                print("카카오 에러메시지:", kakaoError.localizedDescription)
            } else {
                print("에러 메시지:", error.localizedDescription)
            }
        }
    }
    
    /// 애플 로그인 처리 함수
    @MainActor
    public func appleLogin() async {
        container.navigationRouter.push(.baseTab)
    }
}
