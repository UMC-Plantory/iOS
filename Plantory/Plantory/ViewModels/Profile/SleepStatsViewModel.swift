import Foundation
import Combine
import Moya
import CombineMoya

public class SleepStatsViewModel: ObservableObject {
    @Published public private(set) var daily: [DailySleep] = []
    @Published public private(set) var averageText: String = ""
    @Published public private(set) var periodText: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let provider: MoyaProvider<SleepAPI>

    init(provider: MoyaProvider<SleepAPI> = APIManager.shared.testProvider(for: SleepAPI.self)) {
        self.provider = provider
        fetchStats()
    }

    /// 프리뷰 및 커스텀 데이터 주입용 초기화
    public convenience init(response: WeeklySleepResponse) {
        self.init(provider: APIManager.shared.testProvider(for: SleepAPI.self))
        update(with: response)
    }

    private func fetchStats() {
        provider.fetchWeeklyStats()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(err) = completion {
                        print("Error fetching sleep stats:", err)
                    }
                },
                receiveValue: { [weak self] resp in
                    self?.update(with: resp)
                }
            )
            .store(in: &cancellables)
    }

    public func update(with response: WeeklySleepResponse) {
        let model = WeeklySleepStatsModel(from: response)
        daily = model.daily

        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy.MM.dd"
        periodText = "\(dateFmt.string(from: model.startDate)) ~ \(dateFmt.string(from: model.endDate))"

        let h = model.averageHours ?? 0
        let m = model.averageMinutes ?? 0
        averageText = "\(h)h \(m)m"
    }
}
