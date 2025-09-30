// EmotionStatsViewModel.swift

import Foundation
import Combine
import Moya

final class EmotionStatsViewModel: ObservableObject {
    // 기존 프로퍼티
    @Published var response: EmotionStatsResponse?
    @Published var emotionFrequency: [String: Int] = [:]
    @Published var mappedEmotionFrequency: [String: Int] = [:]
    @Published var periodText: String = ""
    @Published var errorMessage: String?

    /// 최다 감정 비율 (0.0 ~ 1.0)
    @Published var topEmotionRatio: Double = 0.0
    /// 최다 감정 키 ("HAPPY", "SAD" 등 서버 키 그대로)
    @Published var topEmotionKey: String = ""
    @Published private(set) var comment: String = ""

    @Published var weeklyLoaded: Bool = false
    @Published var monthlyLoaded: Bool = false
    @Published private(set) var isWeeklyEmpty: Bool = false
    @Published private(set) var isMonthlyEmpty: Bool = false

    // 로딩 인디케이터
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()
    let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        fetchWeeklyEmotionStats()
    }

    // MARK: - Fetch

    func fetchWeeklyEmotionStats() {
        isLoading = true
        weeklyLoaded = false

        container.useCaseService.profileService
            .fetchWeeklyEmotionStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                defer {
                    self.isLoading = false
                    self.weeklyLoaded = true
                }
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    // 서버에서 “데이터 없음” 코드를 사용한다면 여기에 분기해서 비어있음 처리
                    self.isWeeklyEmpty = true
                    self.clearWeeklyUIState()
                }
            } receiveValue: { [weak self] resp in
                guard let self else { return }
                // 비어있는지 판정
                self.isWeeklyEmpty = resp.emotionFrequency.isEmpty
                if self.isWeeklyEmpty {
                    self.clearWeeklyUIState()
                } else {
                    self.handleEmotion(resp, scope: .weekly)
                }
            }
            .store(in: &cancellables)
    }

    func fetchMonthlyEmotionStats() {
        isLoading = true
        monthlyLoaded = false

        container.useCaseService.profileService
            .fetchMonthlyEmotionStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                defer {
                    self.isLoading = false
                    self.monthlyLoaded = true
                }
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.isMonthlyEmpty = true
                    self.clearMonthlyUIState()
                }
            } receiveValue: { [weak self] resp in
                guard let self else { return }
                self.isMonthlyEmpty = resp.emotionFrequency.isEmpty
                if self.isMonthlyEmpty {
                    self.clearMonthlyUIState()
                } else {
                    self.handleEmotion(resp, scope: .monthly)
                }
            }
            .store(in: &cancellables)
    }

    private enum Scope { case weekly, monthly }

    // MARK: - Formatter & Mapping

    private static let isoDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    private static let periodFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 M월 d일"
        return df
    }()

    private static let weekdayMap: [String: String] = [
        "MONDAY": "월요일","TUESDAY": "화요일","WEDNESDAY": "수요일",
        "THURSDAY": "목요일","FRIDAY": "금요일","SATURDAY": "토요일","SUNDAY": "일요일"
    ]

    private static let emotionLabelMap: [String: String] = [
        "HAPPY": "기쁨","AMAZING": "놀람","SAD": "슬픔","ANGRY": "화남","SOSO": "그저그럼"
    ]

    // MARK: - Response Handling

    private func handleEmotion(_ resp: EmotionStatsResponse, scope: Scope) {
        response = resp
        emotionFrequency = resp.emotionFrequency

        // 기간 텍스트
        if let s = Self.isoDateFormatter.date(from: resp.startDate),
           let e = Self.isoDateFormatter.date(from: resp.endDate) {
            periodText = "\(Self.periodFormatter.string(from: s)) ~ \(Self.periodFormatter.string(from: e))"
        } else {
            periodText = "\(resp.startDate) ~ \(resp.endDate)"
        }

        // 키 → 한글 라벨 매핑
        mappedEmotionFrequency = resp.emotionFrequency.reduce(into: [:]) { result, pair in
            let ko = Self.emotionLabelMap[pair.key] ?? pair.key
            result[ko] = pair.value
        }

        // 최다 감정 비율
        let total = resp.emotionFrequency.values.reduce(0, +)
        let topKey = resp.mostFrequentEmotion
        let top = resp.emotionFrequency[topKey] ?? 0
        topEmotionRatio = total > 0 ? Double(top) / Double(total) : 0
        topEmotionKey = topKey

        comment = (scope == .weekly) ? "주간 감정 통계" : "월간 감정 통계"
    }

    // MARK: - Empty UI State

    private func clearWeeklyUIState() {
        response = nil
        emotionFrequency = [:]
        mappedEmotionFrequency = [:]
        topEmotionRatio = 0
        topEmotionKey = ""
        periodText = ""
        comment = "주간 감정 통계"
    }

    private func clearMonthlyUIState() {
        response = nil
        emotionFrequency = [:]
        mappedEmotionFrequency = [:]
        topEmotionRatio = 0
        topEmotionKey = ""
        periodText = ""
        comment = "월간 감정 통계"
    }
}

// MARK: - View-facing helpers
extension EmotionStatsViewModel {
    var todayWeekdayLabel: String {
        guard let resp = response else { return "" }
        return Self.weekdayMap[resp.todayWeekday] ?? resp.todayWeekday
    }

    var mostFrequentEmotionLabel: String {
        guard let resp = response else { return "" }
        return Self.emotionLabelMap[resp.mostFrequentEmotion] ?? resp.mostFrequentEmotion
    }

    struct EmotionPercentage: Identifiable {
        let id: String
        let emotion: String
        let percentage: Double
    }

    var emotionPercentages: [EmotionPercentage] {
        let order = ["기쁨","놀람","슬픔","화남","그저그럼"]
        let total = emotionFrequency.values.reduce(0, +)
        return order.compactMap { label in
            guard let count = mappedEmotionFrequency[label], total > 0 else { return nil }
            return EmotionPercentage(id: label, emotion: label, percentage: (Double(count) / Double(total)) * 100)
        }
    }
}
