//
//  TerrariumViewModel.swift
//  Plantory
//
//  Created by 박정환 on 7/16/25.
//

import SwiftUI
import Combine

@Observable
class TerrariumViewModel {
    var selectedTab: TerrariumTab = .terrarium

    // 테라리움 상태
    var terrariumData: TerrariumResult?
    var isLoading: Bool = false
    var errorMessage: String?

    // 의존성 주입 및 비동기 처리
    let container: DIContainer
    var cancellables = Set<AnyCancellable>()

    init(container: DIContainer) {
        self.container = container
    }

    func fetchTerrarium(memberId: Int) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.terrariumService.getTerrarium(memberId: memberId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "요청 실패: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                // API 래퍼 존재 여부에 따라 TerrariumResult로 매핑
                #if canImport(Moya)
                // 버전 A: 공통 래퍼(APIResponse<T>)가 있는 경우
                // self?.terrariumData = response.result
                // 버전 B: 이미 TerrariumResponse(result: TerrariumResult) 타입을 받는 경우
                self?.terrariumData = response.result
                #else
                self?.terrariumData = response.result
                #endif
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    func waterPlant(memberId: Int) {
        guard let terrariumId = terrariumData?.terrariumId else { return }

        container.useCaseService.terrariumService
            .water(terrariumId: terrariumId, memberId: memberId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "물주기 실패: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] response in
                // 성공 시 최신 상태로 갱신
                self?.terrariumData = response.result
            })
            .store(in: &cancellables)
    }
}
