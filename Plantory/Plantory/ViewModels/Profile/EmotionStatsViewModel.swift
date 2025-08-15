// EmotionStatsViewModel.swift

import Foundation
import Combine
import Moya

final class EmotionStatsViewModel: ObservableObject {
    @Published var response: EmotionStatsResponse?
    @Published var emotionFrequency: [String: Int] = [:]         // 원본 키
    @Published var mappedEmotionFrequency: [String: Int] = [:]   // 한글 매핑된 키
    @Published var periodText: String = ""                       // "yyyy년 M월 d일 ~ yyyy년 M월 d일"
    @Published var errorMessage: String?

    /// 최다 감정 비율 (0.0 ~ 1.0)
    @Published var topEmotionRatio: Double = 0.0
    /// 최다 감정 키 ("joy", "sadness" 등)
    @Published var topEmotionKey: String = ""
    @Published public private(set) var comment: String = ""

    private var cancellables = Set<AnyCancellable>()
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer

    init(
        container: DIContainer
    ) {
        self.container = container
        fetchWeeklyEmotionStats()
    }

    /// 주간 감정 통계 조회
    func fetchWeeklyEmotionStats() {
        container.useCaseService.profileService
            .fetchWeeklyEmotionStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] resp in
                self?.handleEmotion(resp, scope: .weekly)
            }
            .store(in: &cancellables)
    }
    
    func fetchMonthlyEmotionStats() {
            container.useCaseService.profileService
                .fetchMonthlyEmotionStats()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] resp in
                    self?.handleEmotion(resp, scope: .monthly)
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
        "MONDAY":    "월요일",
        "TUESDAY":   "화요일",
        "WEDNESDAY": "수요일",
        "THURSDAY":  "목요일",
        "FRIDAY":    "금요일",
        "SATURDAY":  "토요일",
        "SUNDAY":    "일요일"
    ]

    private static let emotionLabelMap: [String: String] = [
        "HAPPY":      "기쁨",
        "AMAZING": "놀람",
        "SAD":  "슬픔",
        "ANGRY":    "화남",
        "SOSO":     "그저그럼"
    ]

    // MARK: - Response Handling
    private func handleEmotion(_ resp: EmotionStatsResponse, scope: Scope) {
            response = resp
            emotionFrequency = resp.emotionFrequency

            // 기간 포맷
            if let s = Self.isoDateFormatter.date(from: resp.startDate),
               let e = Self.isoDateFormatter.date(from: resp.endDate) {
                periodText = "\(Self.periodFormatter.string(from: s)) ~ \(Self.periodFormatter.string(from: e))"
            } else {
                periodText = "\(resp.startDate) ~ \(resp.endDate)"
            }

            // 라벨 매핑 (대문자 키 그대로)
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

            comment = scope == .weekly ? "주간 감정 통계" : "월간 감정 통계"
        }
}

// MARK: - ViewModel Extensions (뷰용 데이터)
extension EmotionStatsViewModel {
    /// 한글 요일 (뷰에서 바로 사용)
    var todayWeekdayLabel: String {
        guard let resp = response else { return "" }
        return Self.weekdayMap[resp.todayWeekday] ?? resp.todayWeekday
    }

    /// 한글 감정 레이블 (뷰에서 바로 사용)
    var mostFrequentEmotionLabel: String {
        guard let resp = response else { return "" }
        return Self.emotionLabelMap[resp.mostFrequentEmotion] ?? resp.mostFrequentEmotion
    }
    
    /// 차트용 감정 점유율 모델
        struct EmotionPercentage: Identifiable {
            let id: String              // emotion label
            let emotion: String         // 한글 레이블
            let percentage: Double      // 0.0 ~ 100.0
        }

        /// 감정 빈도에서 점유율 계산 (한글 레이블 순서 보장)
        var emotionPercentages: [EmotionPercentage] {
            let order = ["기쁨", "놀람", "슬픔", "화남", "그저그럼"]
            let total = emotionFrequency.values.reduce(0, +)
            return order.compactMap { label in
                guard let count = mappedEmotionFrequency[label], total > 0 else { return nil }
                let pct = (Double(count) / Double(total)) * 100
                return EmotionPercentage(id: label, emotion: label, percentage: pct)
            }
        }
}
