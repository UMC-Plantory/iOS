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

protocol HomeServiceProtocol{
    /// 홈 월간 데이터 조회 (yearMonth 미입력 시 이번 달)
    func getMonthly(yearMonth: String?) -> AnyPublisher<HomeMonthlyResult, APIError>

    /// 특정 날짜 일기 요약 조회 (일기 없으면 DIARY4001 매핑)
    func getDiarySummary(date: String) -> AnyPublisher<HomeDiaryResult, APIError>
}

//Home API를 사용하는 서비스

