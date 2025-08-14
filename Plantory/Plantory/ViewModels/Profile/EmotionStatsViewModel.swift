// EmotionStatsViewModel.swift

import Foundation
import Combine
import Moya

final class EmotionStatsViewModel: ObservableObject {
    @Published var response: WeeklyEmotionResponse?
    @Published var emotionFrequency: [String: Int] = [:]         // 원본 키
    @Published var mappedEmotionFrequency: [String: Int] = [:]   // 한글 매핑된 키
    @Published var periodText: String = ""                       // "yyyy년 M월 d일 ~ yyyy년 M월 d일"
    @Published var errorMessage: String?

    /// 최다 감정 비율 (0.0 ~ 1.0)
    @Published var topEmotionRatio: Double = 0.0
    /// 최다 감정 키 ("joy", "sadness" 등)
    @Published var topEmotionKey: String = ""
    @Published public private(set) var comment: String = ""

    private let provider: MoyaProvider<ProfileRouter>
    private var cancellables = Set<AnyCancellable>()
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer

    init(
        provider: MoyaProvider<ProfileRouter> = APIManager.shared.testProvider(for: ProfileRouter.self),
        container: DIContainer
    ) {
        self.provider = provider
        self.container = container
        fetchWeeklyEmotionStats()
    }

    /// 주간 감정 통계 조회
    func fetchWeeklyEmotionStats() {
        let today = Self.isoDateFormatter.string(from: Date())
        container.useCaseService.profileService
            .fetchWeeklyEmotionStats(today: today)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] resp in
                self?.handleWeeklyEmotion(resp)
            }
            .store(in: &cancellables)
    }

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
        "monday":    "월요일",
        "tuesday":   "화요일",
        "wednesday": "수요일",
        "thursday":  "목요일",
        "friday":    "금요일",
        "saturday":  "토요일",
        "sunday":    "일요일"
    ]

    private static let emotionLabelMap: [String: String] = [
        "joy":      "기쁨",
        "surprise": "놀람",
        "sadness":  "슬픔",
        "anger":    "화남",
        "soso":     "그저그럼"
    ]

    // MARK: - Response Handling

    private func handleWeeklyEmotion(_ resp: WeeklyEmotionResponse) {
        response = resp
        emotionFrequency = resp.emotionFrequency

        // 1) 기간 텍스트 설정
        periodText = "\(Self.periodFormatter.string(from: resp.startDate)) ~ " +
                     "\(Self.periodFormatter.string(from: resp.endDate))"

        // 2) 감정 키를 한글로 매핑
        mappedEmotionFrequency = resp.emotionFrequency.reduce(into: [:]) { result, pair in
            let korean = Self.emotionLabelMap[pair.key] ?? pair.key
            result[korean] = pair.value
        }

        // 3) 최다 감정 비율 및 키 계산
        let totalCount = resp.emotionFrequency.values.reduce(0, +)
        let topKey = resp.mostFrequentEmotion
        let topCount = resp.emotionFrequency[topKey] ?? 0
        topEmotionRatio = totalCount > 0 ? Double(topCount) / Double(totalCount) : 0
        topEmotionKey = topKey
        
        comment = "주간 감정 통계"
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
