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

    // 화면에 띄울 테라리움 데이터 (도메인 모델)
    var terrariumData: TerrariumResult?
    var lastWateringResult: WateringResult?

    /// 로딩 중임을 나타냄
    var isLoading: Bool = false

    /// 에러 메시지
    var errorMessage: String?

    // MARK: - 의존성 주입 및 비동기 처리
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()

    // MARK: - Debug Helper
    private func log(_ message: String) {
        print("[TerrariumVM] \(message)")
    }
    
    /// yyyy-MM 포맷 검증용 (실패 시 로그만 남김)
    private func validateYearMonth(_ month: String) {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM"
        if f.date(from: month) == nil {
            print("[TerrariumVM][WARN] 잘못된 월 포맷 전달됨 => \(month). 기대 포맷: yyyy-MM")
        }
    }

    // MARK: - 초기화
    init(container: DIContainer) {
        self.container = container
    }

    // MARK: - API
    // 테라리움 상태 조회
    public func fetchTerrarium() {
        isLoading = true
        errorMessage = nil

        container.useCaseService.terrariumService
            .getTerrarium()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let failure) = completion {
                    self?.errorMessage = "테라리움 조회 실패: \(failure.localizedDescription)"
                    self?.isLoading = false
                    print("API 요청 실패: \(failure.localizedDescription)") // 실패 시 로그
                }
            }, receiveValue: { [weak self] response in
                print("테라리움 조회 응답: \(response)")  // 응답이 제대로 들어왔는지 확인
                let result = response
                    // terrariumData를 업데이트
                self?.terrariumData = result
                    // 데이터 업데이트가 되었는지 확인
                    print("업데이트된 terrariumData: \(String(describing: self?.terrariumData))")
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    // 물주기 액션
    public func waterPlant() {
        guard let terrariumId = terrariumData?.terrariumId else {
            print("Error: terrariumId is nil")
            return
        }
        isLoading = true
        print("Watering plant with terrariumId: \(terrariumId)")  // 물주기 시작 로그

        container.useCaseService.terrariumService
            .water(terrariumId: terrariumId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let failure) = completion {
                    self?.errorMessage = "물주기 실패: \(failure.localizedDescription)"
                    self?.isLoading = false
                    print("API 요청 실패: \(failure.localizedDescription)")  // 실패 로그
                }
            }, receiveValue: { [weak self] result in

                // 물주기 후 terrariumData 갱신
                self?.terrariumData?.terrariumWateringCount = result.terrariumWateringCountAfterEvent
                self?.terrariumData?.memberWateringCount = result.memberWateringCountAfterEvent
                
                self?.lastWateringResult = result

                print("업데이트된 terrariumData: \(String(describing: self?.terrariumData))")  // 업데이트된 데이터 로그

                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    var wateringMessage: String {
        guard let wateringCount = terrariumData?.terrariumWateringCount else {
            return "<잎새>까지 0번 남았어요!"
        }

        if wateringCount < 3 {
            return "<잎새>까지 \(3 - wateringCount)번 남았어요!"
        } else {
            return "<꽃나무>까지 \(7 - wateringCount)번 남았어요!"
        }
    }

    // MARK: - 월별 응답 파싱용 로컬 DTO & 날짜 매핑
    /// API에서 내려오는 원본(문자열 날짜 포함)을 임시로 받기 위한 로컬 DTO
    private func parseBloomDate(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    // 기존 mapMonthly 제거 후 아래로 교체
    private func mapMonthlyResult(_ raw: TerrariumMonthlyResultRaw) -> TerrariumMonthlyResult {
        let items: [TerrariumMonthlyListItem] = raw.terrariumList.compactMap { e in
            guard let date = parseBloomDate(e.bloomAt) else {
                print("[TerrariumVM] 날짜 파싱 실패: \(e.bloomAt)")
                return nil
            }
            return TerrariumMonthlyListItem(
                terrariumId: e.terrariumId,
                bloomAt: date,
                flowerName: e.flowerName
            )
        }
        .sorted { $0.bloomAt < $1.bloomAt }

        return TerrariumMonthlyResult(nickname: raw.nickname, terrariumList: items)
    }

    // MARK: - 월별 테라리움 상태 & API

    /// 월별 테라리움 리스트 (도메인 모델)
    var monthlyTerrariums: [TerrariumMonthlyListItem] = []
    /// 월별 응답의 닉네임 (옵션)
    var monthlyNickname: String?

    /// 월 전환을 위한 현재 선택 월 (기본: 오늘)
    var selectedMonth: Date = Date()

    /// 월별 데이터 조회 (YYYY-MM 문자열을 직접 받는 버전)
    public func fetchMonthlyTerrarium(month: String) {
        isLoading = true
        errorMessage = nil

        log("fetchMonthlyTerrarium(month:) 호출 — month=\(month)")
        validateYearMonth(month)

        container.useCaseService.terrariumService
            .getMonthlyTerrarium(month: month)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.log("fetchMonthlyTerrarium — 완료(.finished)")
                case .failure(let failure):
                    self?.errorMessage = "월별 조회 실패: \(failure.localizedDescription)"
                    self?.isLoading = false
                    self?.log("fetchMonthlyTerrarium — 실패: \(failure.localizedDescription)")
                }
            }, receiveValue: { [weak self] rawResult in
                guard let self = self else { return }
                // Service가 TerrariumMonthlyResultRaw 를 반환 -> 도메인으로 매핑
                let result = self.mapMonthlyResult(rawResult)
                self.monthlyNickname = result.nickname
                let items = result.terrariumList
                self.log("fetchMonthlyTerrarium — 응답 수신 개수: \(items.count)")
                if let first = items.first, let last = items.last {
                    self.log("fetchMonthlyTerrarium — 기간: \(first.bloomAt) ~ \(last.bloomAt)")
                }
                self.monthlyTerrariums = items
                self.isLoading = false
                self.log("fetchMonthlyTerrarium — monthlyTerrariums 업데이트 count=\(self.monthlyTerrariums.count)")
            })
            .store(in: &cancellables)
    }

    /// 월별 데이터 조회 (선택된 Date를 사용하여 YYYY-MM로 포맷)
    public func fetchMonthlyTerrarium() {
        log("fetchMonthlyTerrarium() 호출 — selectedMonth=\(selectedMonth)")
        let monthString = Self.formatYearMonth(selectedMonth)
        log("fetchMonthlyTerrarium() — 포맷된 monthString=\(monthString)")
        fetchMonthlyTerrarium(month: monthString)
    }

    /// 이전 달로 이동 후 조회
    public func goToPreviousMonth() {
        log("goToPreviousMonth 호출 — 현재 selectedMonth=\(selectedMonth)")
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
            log("goToPreviousMonth — 변경된 selectedMonth=\(selectedMonth)")
            let monthString = Self.formatYearMonth(selectedMonth)
            log("goToPreviousMonth — 요청 monthString=\(monthString)")
            fetchMonthlyTerrarium(month: monthString)
        } else {
            log("goToPreviousMonth — 날짜 계산 실패")
        }
    }

    /// 다음 달로 이동 후 조회
    public func goToNextMonth() {
        log("goToNextMonth 호출 — 현재 selectedMonth=\(selectedMonth)")
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
            log("goToNextMonth — 변경된 selectedMonth=\(selectedMonth)")
            let monthString = Self.formatYearMonth(selectedMonth)
            log("goToNextMonth — 요청 monthString=\(monthString)")
            fetchMonthlyTerrarium(month: monthString)
        } else {
            log("goToNextMonth — 날짜 계산 실패")
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
