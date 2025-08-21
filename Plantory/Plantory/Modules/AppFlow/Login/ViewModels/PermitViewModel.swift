//
//  PermitViewModel.swift
//  Plantory
//
//  Created by 주민영 on 7/8/25.
//

import SwiftUI
import Observation
import Combine

@Observable
class PermitViewModel {
    
    // MARK: - Toast
    
    var toast: CustomToast? = nil
    
    // MARK: - 로딩
    
    var isLoading = false
    
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
    
    // MARK: - States
    
    var allPermit: Bool {
        get {
            termsOfServicePermit &&
            informationPermit &&
            marketingPermit        }
        set {
            withAnimation {
                termsOfServicePermit = newValue
                informationPermit = newValue
                marketingPermit = newValue
            }
        }
    }
    
    var termsOfServicePermit: Bool = false
    var informationPermit: Bool = false
    var marketingPermit: Bool = false
    
    // MARK: - API 요청을 위한 Int 배열
    
    var agreeTermIdList: [Int] = []
    var disagreeTermIdList: [Int] = []
    
    // MARK: - 함수
    
    func nextButtonTapped() async throws {
        updateTermLists()
        try await postAgreements()
    }
    
    private func updateTermLists() {
        agreeTermIdList.removeAll()
        disagreeTermIdList.removeAll()
        
        let permits = [
            (termsOfServicePermit, 1),
            (informationPermit, 2),
            (marketingPermit, 3)
        ]
        
        for (permit, id) in permits {
            if permit {
                agreeTermIdList.append(id)
            } else {
                disagreeTermIdList.append(id)
            }
        }
    }
    
    // MARK: - API
    
    /// 서비스 이용 동의 API 호출
    private func postAgreements() async throws {
        self.isLoading = true
        
        let request = AgreementsRequest(
            agreeTermIdList: agreeTermIdList,
            disagreeTermIdList: disagreeTermIdList
        )
        
        container.useCaseService.authService.postAgreements(request: request)
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
                // post 성공 시, 개인정보 입력 뷰로 이동
                self?.container.navigationRouter.push(.profileInfo)
                
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
}
