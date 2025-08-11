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

/// 테라리움 서비스 프로토콜
protocol TerrariumServiceProtocol {
    /// 테라리움 상태 조회
    func getTerrarium(memberId: Int) -> AnyPublisher<TerrariumResponse, APIError>
    /// 물 주기
    func water(terrariumId: Int, memberId: Int) -> AnyPublisher<TerrariumResponse, APIError>
    /// 월별 테라리움 데이터 조회
    func getMonthlyTerrarium(memberId: Int, month: String) -> AnyPublisher<TerrariumMonthlyResponse, APIError>
    /// 테라리움 상세 조회
    func getTerrariumDetail(terrariumId: Int) -> AnyPublisher<TerrariumDetailResponse, APIError>
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
    func getTerrarium(memberId: Int) -> AnyPublisher<TerrariumResponse, APIError> {
        return provider.requestResult(.getTerrarium(memberId: memberId), type: TerrariumResponse.self)
    }

    /// 물 주기
    func water(terrariumId: Int, memberId: Int) -> AnyPublisher<TerrariumResponse, APIError> {
        return provider.requestResult(.water(terrariumId: terrariumId, memberId: memberId), type: TerrariumResponse.self)
    }

    /// 월별 테라리움 데이터 조회
    func getMonthlyTerrarium(memberId: Int, month: String) -> AnyPublisher<TerrariumMonthlyResponse, APIError> {
        return provider.requestResult(.getMonthlyTerrarium(memberId: memberId, month: month), type: TerrariumMonthlyResponse.self)
    }

    /// 테라리움 상세 조회
    func getTerrariumDetail(terrariumId: Int) -> AnyPublisher<TerrariumDetailResponse, APIError> {
        return provider.requestResult(.getTerrariumDetail(terrariumId: terrariumId), type: TerrariumDetailResponse.self)
    }
}
