//
//  TerrariumViewModel.swift
//  Plantory
//
//  Created by 박정환 on 7/16/25.
//

import SwiftUI
import Moya

class TerrariumViewModel: ObservableObject {
    @Published var selectedTab: TerrariumTab = .terrarium
    
    // 1. 테라리움 응답 모델
    @Published var terrariumData: TerrariumResult?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // 2. Moya Provider
    private let provider: MoyaProvider<TerrariumRouter>

    init() {
        self.provider = APIManager.shared.testProvider(for: TerrariumRouter.self)
    }

    // 3. API 요청 함수
    func fetchTerrarium(memberId: Int) {
        isLoading = true
        errorMessage = nil
        
        provider.request(.getTerrarium(memberId: memberId)) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(TerrariumResponse.self, from: response.data)
                        self?.terrariumData = decoded.result
                    } catch {
                        self?.errorMessage = "디코딩 실패: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    self?.errorMessage = "요청 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func waterPlant(memberId: Int) {
        guard let terrariumId = terrariumData?.terrariumId else { return }

        provider.request(.water(terrariumId: terrariumId, memberId: memberId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("🌿 물주기 성공")
                    self?.fetchTerrarium(memberId: memberId)
                case .failure(let error):
                    self?.errorMessage = "물주기 실패: \(error.localizedDescription)"
                }
            }
        }
    }
}
