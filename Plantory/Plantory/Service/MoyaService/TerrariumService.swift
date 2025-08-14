//
//  TerrariumService.swift
//  Plantory
//
//  Created by 박정환 on 8/10/25.
//

import Foundation
import CombineMoya
import Moya
import Combine

// MARK: - Terrarium Service

/// 테라리움 서비스 프로토콜
protocol TerrariumServiceProtocol {
    /// 테라리움 상태 조회
    func getTerrarium() -> AnyPublisher<TerrariumResult, APIError>
    /// 물 주기
    func water(terrariumId: Int) -> AnyPublisher<WateringResult, APIError>
    /// 월별 테라리움 데이터 조회
    func getMonthlyTerrarium(month: String) -> AnyPublisher<TerrariumMonthly, APIError>
    /// 테라리움 상세 조회
    func getTerrariumDetail(terrariumId: Int) -> AnyPublisher<TerrariumDetail, APIError>
}

/// Terrarium API를 사용하는 서비스
final class TerrariumService: TerrariumServiceProtocol {

    /// MoyaProvider를 통해 API 요청을 전송
    let provider: MoyaProvider<TerrariumRouter>

    // MARK: - Initializer
    /// APIManager의 공통 provider 사용(토큰 헤더 포함)
    init(provider: MoyaProvider<TerrariumRouter> = APIManager.shared.createProvider(for: TerrariumRouter.self)) {
        self.provider = provider
    }

    // MARK: - API

    /// 테라리움 상태 조회
    func getTerrarium() -> AnyPublisher<TerrariumResult, APIError> {
        return provider.requestResult(.getTerrarium, type: TerrariumResult.self)
    }

    /// 물 주기
    func water(terrariumId: Int) -> AnyPublisher<WateringResult, APIError> {
        return provider.requestResult(.water(terrariumId: terrariumId), type: WateringResult.self)
    }

    /// 월별 테라리움 데이터 조회
    func getMonthlyTerrarium(month: String) -> AnyPublisher<TerrariumMonthly, APIError> {
        return provider.requestResult(.getMonthlyTerrarium(month: month), type: TerrariumMonthly.self)
    }

    /// 테라리움 상세 조회
    func getTerrariumDetail(terrariumId: Int) -> AnyPublisher<TerrariumDetail, APIError> {
        return provider.requestResult(.getTerrariumDetail(terrariumId: terrariumId), type: TerrariumDetail.self)
    }
}
