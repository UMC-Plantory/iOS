//
//  HomeViewModel.swift
//  Plantory
//
//  Created by 김지우 on 8/13/25.
//


import Foundation
import Combine
import Moya
import SwiftUI

@Observable
class HomeViewModel {

    // MARK: - 의존성 & 비동기
    let container: DIContainer
    var cancellables = Set<AnyCancellable>()

    // MARK: - 입력(상태)
    var month: Date = Date()              // 현재 보여줄 달
    var selectedDate: Date?               // 사용자가 선택한 날짜

    // MARK: - 출력(뷰 바인딩용)
    var wateringProgress: Int = 0
    var continuousRecordCnt: Int = 0
    /// "yyyy-MM-dd" -> "HAPPY"/"SAD" ...
    var diaryEmotionsByDate: [String: String] = [:]
    
    // MARK: - 년/월 선택 모달용
    var displayYear: Int {
        Calendar.current.component(.year, from: month)
    }
    var displayMonth: Int {
        Calendar.current.component(.month, from: month)
    }
    
    var emotionPalette: [String: Color] = [
            "HAPPY":   .happy,
            "SAD":     .sad,
            "ANGRY":   .mad,
            "SOSO":    .soso,
            "AMAZING": .surprised
        ]

    var diarySummary: HomeDiaryResult?
    var noDiaryForSelectedDate: Bool = false

    var isLoadingMonthly: Bool = false
    var isLoadingDiary: Bool = false
    var requiresLogin: Bool = false
    var errorMessage: String?

    // MARK: - 초기화
    init(container: DIContainer) {
        self.container = container
    }

    

    ///감정 코드 색으로 변경하는 함수
    func color(for emotionCode: String) -> Color? {
            emotionPalette[emotionCode.uppercased()]
    }

    ///날짜별 색상
    func colorForDate(_ date: Date) -> Color? {
        let key = Self.formatYMD(date)
        guard let code = diaryEmotionsByDate[key] else { return nil }
        return color(for: code)
    }
    
    // MARK: - API
    /// 화면 진입/달 변경 시 호출
    func loadMonthly() {
        isLoadingMonthly = true
        errorMessage = nil
        requiresLogin = false

        let ym = Self.formatYearMonth(month)
        container.useCaseService.homeService.getHomeMonthly(yearMonth: ym)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoadingMonthly = false
                if case let .failure(err) = completion { self.handleMonthlyError(err) }
            } receiveValue: { [weak self] result in
                guard let self else { return }
                self.wateringProgress = result.wateringProgress
                self.continuousRecordCnt = result.continuousRecordCnt
                self.diaryEmotionsByDate = Dictionary(
                    uniqueKeysWithValues: result.diaryDates.map { ($0.date, $0.emotion) }
                )
            }
            .store(in: &cancellables)
    }

    /// 날짜 선택 시 호출 (미래 날짜는 요약 요청 X)
    func selectDate(_ date: Date) {
        selectedDate = date
        let cal = Calendar.current
        if cal.startOfDay(for: date) > cal.startOfDay(for: Date()) {
            diarySummary = nil
            noDiaryForSelectedDate = false
            return
        }
        loadDiarySummary(for: date)
    }

    /// 달 이동 (±1)
    func moveMonth(by offset: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: month) {
            month = newMonth
            selectedDate = nil
            diarySummary = nil
            noDiaryForSelectedDate = false
            loadMonthly()
        }
    }

    // MARK: - Private

    private func loadDiarySummary(for date: Date) {
        isLoadingDiary = true
        errorMessage = nil
        requiresLogin = false
        noDiaryForSelectedDate = false

        let dateString = Self.formatYMD(date)
        container.useCaseService.homeService.getHomeDiary(date: dateString)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoadingDiary = false
                if case let .failure(err) = completion { self.handleDiaryError(err) }
            } receiveValue: { [weak self] result in
                self?.diarySummary = result
            }
            .store(in: &cancellables)
    }

    private func handleMonthlyError(_ err: APIError) {
        switch err {
        case let .serverError(code, message):
            switch code {
            case "COMMON401", "JWT4001", "JWT4002":
                requiresLogin = true
            case "MEMBER4001":
                errorMessage = "존재하지 않는 회원입니다."
            case "MEMBER4013":
                errorMessage = "날짜 형식이 올바르지 않습니다."
            default:
                errorMessage = message
            }
        case let .moyaError(moya):
            errorMessage = moya.localizedDescription
        default:
            errorMessage = "알 수 없는 오류가 발생했습니다."
        }
    }

    private func handleDiaryError(_ err: APIError) {
        switch err {
        case let .serverError(code, message):
            if code == "DIARY4001" {
                diarySummary = nil
                noDiaryForSelectedDate = true
            } else if ["COMMON401","JWT4001","JWT4002"].contains(code) {
                requiresLogin = true
            } else {
                errorMessage = message
            }
        case let .moyaError(moya):
            errorMessage = moya.localizedDescription
        default:
            errorMessage = "알 수 없는 오류가 발생했습니다."
        }
    }

    // MARK: - Formatting
    private static func formatYearMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }

    private static func formatYMD(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    func setMonth(year: Int, month m: Int) {
        // 월 범위 안전화 (1...12)
        let safeMonth = max(1, min(m, 12))

        var comps = DateComponents()
        comps.year = year
        comps.month = safeMonth
        comps.day = 1

        if let newMonth = Calendar.current.date(from: comps) {
            self.month = newMonth
            // 날짜 관련 상태 초기화
            self.selectedDate = nil
            self.diarySummary = nil
            self.noDiaryForSelectedDate = false
            // 월간 데이터 재조회
            loadMonthly()
        }
    }
}
