//
//  HomeService.swift
//  Plantory
//
//  Created by 김지우 on 8/12/25.
//

import Foundation
import CombineMoya
import Moya
import Combine

protocol HomeServiceProtocol {
    /// 홈 월간 데이터 조회 (yearMonth 미입력 시 이번 달)
    func getHomeMonthly(yearMonth: String?) -> AnyPublisher<HomeMonthlyResult, APIError>

    /// 특정 날짜 일기 요약 조회 (일기 없으면 DIARY4001 매핑)
    func getHomeDiary(date: String) -> AnyPublisher<HomeDiaryResult, APIError>
}

/// Home API를 사용하는 서비스
final class HomeService: HomeServiceProtocol {
    /// MoyaProvider를 통해 API 요청을 전송
    private let provider: MoyaProvider<HomeRouter>

    // MARK: - Initializer
    /// 기본 initializer - verbose 로그 플러그인을 포함한 provider 생성
    init(provider: MoyaProvider<HomeRouter> = APIManager.shared.createProvider(for: HomeRouter.self)) {
        self.provider = provider
    }

    // MARK: - Requests
    func getHomeMonthly(yearMonth: String?) -> AnyPublisher<HomeMonthlyResult, APIError> {
        return provider.requestResult(.getHomeMonthly(yearMonth: yearMonth), type: HomeMonthlyResult.self)
    }

    func getHomeDiary(date: String) -> AnyPublisher<HomeDiaryResult, APIError> {
        return provider.requestResult(.getHomeDiary(date: date), type: HomeDiaryResult.self)
    }
}
