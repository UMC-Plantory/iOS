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
    /// 테라리움 조회
    func getTerrarium(memberId: Int) -> AnyPublisher<APIResponse<TerrariumDTO>, APIError>
    /// 물 주기
    func water(terrariumId: Int, memberId: Int) -> AnyPublisher<APIResponse<TerrariumDTO>, APIError>
}

/// Terrarium API를 사용하는 서비스
final class TerrariumService: TerrariumServiceProtocol {

    /// MoyaProvider를 통해 API 요청 전송
    let provider: MoyaProvider<TerrariumRouter>

    // MARK: - Initializer
    init(provider: MoyaProvider<TerrariumRouter> = APIManager.shared.createProvider(for: TerrariumRouter.self)) {
        self.provider = provider
    }

    // MARK: - API
    func getTerrarium(memberId: Int) -> AnyPublisher<APIResponse<TerrariumDTO>, APIError> {
        provider.requestResult(.getTerrarium(memberId: memberId),
                               type: APIResponse<TerrariumDTO>.self)
    }

    func water(terrariumId: Int, memberId: Int) -> AnyPublisher<APIResponse<TerrariumDTO>, APIError> {
        provider.requestResult(.water(terrariumId: terrariumId, memberId: memberId),
                               type: APIResponse<TerrariumDTO>.self)
    }
}

/// 서버 result 필드용 DTO (필요 시 프로젝트의 기존 모델로 교체)
struct TerrariumDTO: Codable, Equatable {
    let terrariumId: Int
    let flowerImgUrl: String
    let terrariumWateringCount: Int
    let memberWateringCount: Int
}
