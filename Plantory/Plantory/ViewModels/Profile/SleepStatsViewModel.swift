// SleepStatsViewModel.swift
import Foundation
import Combine
import Moya
import CombineMoya

public class SleepStatsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var daily: [DailySleep] = []
    @Published public private(set) var weekly: [WeeklySleep] = []
    @Published public private(set) var periodText: String = ""
    @Published public private(set) var averageText: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let provider: MoyaProvider<SleepAPI>

    // MARK: - Init
    init(provider: MoyaProvider<SleepAPI> = APIManager.shared.testProvider(for: SleepAPI.self)) {
        self.provider = provider
        fetchWeekly()    // 최초 로드시 주간 데이터 페치
    }

    // MARK: - Fetch Methods
    public func fetchWeekly() {
        provider.fetchWeeklyStats()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(err) = completion {
                        print("Error fetching weekly stats:", err)
                    }
                },
                receiveValue: { [weak self] resp in
                    self?.updateWeekly(with: resp)
                }
            )
            .store(in: &cancellables)
    }

    public func fetchMonthly() {
        provider.fetchMonthlyStats()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(err) = completion {
                        print("Error fetching monthly stats:", err)
                    }
                },
                receiveValue: { [weak self] resp in
                    self?.updateMonthly(with: resp)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Update Helpers
    public func updateWeekly(with response: WeeklySleepResponse) {
        let model = WeeklySleepStatsModel(from: response)
        daily = model.daily

        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        periodText = "\(df.string(from: model.startDate)) ~ \(df.string(from: model.endDate))"

        let h = model.averageHours ?? 0
        let m = model.averageMinutes ?? 0
        averageText = "\(h)h \(m)m"
    }

    public func updateMonthly(with response: MonthlySleepResponse) {
        let model = MonthlySleepStatsModel(from: response)
        weekly = model.weekly

        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        periodText = "\(df.string(from: model.startDate)) ~ \(df.string(from: model.endDate))"

        let h = model.averageHours ?? 0
        let m = model.averageMinutes ?? 0
        averageText = "\(h)h \(m)m"
    }
}
