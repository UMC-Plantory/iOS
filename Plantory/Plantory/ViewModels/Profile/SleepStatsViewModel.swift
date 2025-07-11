import Foundation
import Combine
import Moya
import CombineMoya

/// SleepStatsViewModel.swift
/// 리팩토링된 뷰모델 전체 코드 (주간/월간 지원)
public class SleepStatsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var daily: [DailySleep]        = []
    @Published public private(set) var monthly: [WeeklySleep]    = []
    @Published public private(set) var todayWeekday: String      = ""
    @Published public private(set) var periodText: String        = ""
    @Published public private(set) var averageText: String       = ""
    @Published public private(set) var averageComment: String    = ""

    // MARK: - Dependencies
    private let provider: MoyaProvider<ProfileRouter>
    private let calendar: Calendar
    private let today: Date
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Formatters & Mappings
    private static let periodFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        return df
    }()
    private static let koreanWeekdays = ["일","월","화","수","목","금","토"]

    // MARK: - Init
    /// 의존성 주입으로 테스트 용이성 확보
    init(
        provider: MoyaProvider<ProfileRouter> = APIManager.shared.testProvider(for: ProfileRouter.self),
        calendar: Calendar = .current,
        today: Date = Date()
    ) {
        self.provider = provider
        self.calendar = calendar
        self.today = today
        fetchWeekly()
    }

    // MARK: - API Fetch
    /// 주간 통계 호출
    public func fetchWeekly() {
        provider.fetchWeeklyStats()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error fetching weekly stats:", error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleWeekly(response)
                }
            )
            .store(in: &cancellables)
    }

    /// 월간 통계 호출
    public func fetchMonthly() {
        provider.fetchMonthlyStats()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error fetching monthly stats:", error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleMonthly(response)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Handlers
    private func handleWeekly(_ response: WeeklySleepResponse) {
        // 모델 변환
        let model = WeeklySleepStatsModel(from: response, calendar: calendar)
        daily = model.daily

        // 오늘 요일 한글 매핑
        let idx = calendar.component(.weekday, from: today) - 1
        todayWeekday = Self.koreanWeekdays[idx]

        // 기간 텍스트 설정
        periodText = "\(Self.periodFormatter.string(from: model.startDate)) ~ " +
                     "\(Self.periodFormatter.string(from: model.endDate))"

        // 평균 시간 텍스트 및 코멘트
        averageText    = "\(model.averageHours ?? 0)h \(model.averageMinutes ?? 0)m"
        averageComment = model.comment
    }

    private func handleMonthly(_ response: MonthlySleepResponse) {
        // 모델 변환
        let model = MonthlySleepStatsModel(from: response)
        monthly = model.weekly

        // 기간 텍스트 설정
        periodText = "\(Self.periodFormatter.string(from: model.startDate)) ~ " +
                     "\(Self.periodFormatter.string(from: model.endDate))"

        // 평균 시간 텍스트 및 코멘트
        averageText    = "\(model.averageHours ?? 0)h \(model.averageMinutes ?? 0)m"
        averageComment = model.comment
    }
}
