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
    // MARK: - 상태
    /// 현재 선택된 탭
    var selectedTab: TerrariumTab = .terrarium

    /// 화면에 띄울 테라리움 데이터 (도메인 모델)
    var terrariumData: TerrariumResult?

    /// 로딩 중임을 나타냄
    var isLoading: Bool = false

    /// 에러 메시지
    var errorMessage: String?

    // MARK: - 의존성 주입 및 비동기 처리
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()

    // MARK: - 초기화
    init(container: DIContainer) {
        self.container = container
    }

    // MARK: - API
    /// 테라리움 조회
    public func fetchTerrarium(memberId: Int) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.terrariumService.getTerrarium(memberId: memberId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let failure) = completion {
                    self?.errorMessage = "요청 실패: \(failure.localizedDescription)"
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                self?.terrariumData = TerrariumResult(dto: response.result)
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    /// 물주기 액션
    public func waterPlant(memberId: Int) {
        guard let terrariumId = terrariumData?.terrariumId else { return }
        isLoading = true

        container.useCaseService.terrariumService
            .water(terrariumId: terrariumId, memberId: memberId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let failure) = completion {
                    self?.errorMessage = "물주기 실패: \(failure.localizedDescription)"
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                self?.terrariumData = TerrariumResult(dto: response.result)
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    // MARK: - 월별 테라리움 상태 & API

    /// 월별 테라리움 리스트 (도메인 모델)
    var monthlyTerrariums: [TerrariumMonthly] = []

    /// 월 전환을 위한 현재 선택 월 (기본: 오늘)
    var selectedMonth: Date = Date()

    /// 월별 데이터 조회 (YYYY-MM 문자열을 직접 받는 버전)
    public func fetchMonthlyTerrarium(memberId: Int, month: String) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.terrariumService
            .getMonthlyTerrarium(memberId: memberId, month: month)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let failure) = completion {
                    self?.errorMessage = "월별 조회 실패: \(failure.localizedDescription)"
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                self?.monthlyTerrariums = response.result.map { TerrariumMonthly(dto: $0) }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    /// 월별 데이터 조회 (선택된 Date를 사용하여 YYYY-MM로 포맷)
    public func fetchMonthlyTerrarium(memberId: Int) {
        let monthString = Self.formatYearMonth(selectedMonth)
        fetchMonthlyTerrarium(memberId: memberId, month: monthString)
    }

    /// 이전 달로 이동 후 조회
    public func goToPreviousMonth(memberId: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
            fetchMonthlyTerrarium(memberId: memberId)
        }
    }

    /// 다음 달로 이동 후 조회
    public func goToNextMonth(memberId: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
            fetchMonthlyTerrarium(memberId: memberId)
        }
    }

    /// YYYY-MM 포맷터
    private static func formatYearMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }
}
