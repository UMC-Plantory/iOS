//
//  LoginViewModel.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation
import Combine

/// 로그인 화면에서 사용되는 ViewModel
/// 사용자 ID/비밀번호 로그인 및 카카오 로그인 기능을 제공하며, 키체인과 앱 흐름 전환을 관리함
@Observable
class LoginViewModel {
    
    // MARK: - 의존성 주입 및 비동기 처리
    
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()
    
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
            let idToken = try await container.useCaseService.kakaoManager.login()
            container.useCaseService.authService.kakaoLogin(idToken: idToken)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("로그인 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                    }
                }, receiveValue: { [weak self] response in
                    let tokenInfo = TokenInfo(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken
                    )
                    /// 받은 토큰을 키체인에 저장
                    self?.keychainManager.saveToken(tokenInfo)
                    
                    /// 서비스 이용 동의 뷰로 이동
                    self?.container.navigationRouter.push(.permit)
                })
                .store(in: &cancellables)
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
