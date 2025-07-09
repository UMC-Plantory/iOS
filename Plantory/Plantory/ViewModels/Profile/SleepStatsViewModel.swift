//
// SleepStatsViewModel.swift
//

import Foundation
import Combine
import Moya
import CombineMoya

/// ViewModel: 수면 통계 데이터를 Fetch하고 가공하여 View에 바인딩합니다
public class SleepStatsViewModel: ObservableObject {
    // MARK: - Published Properties

    /// 일별 수면 데이터 배열
    @Published public private(set) var daily: [DailySleep] = []
    /// 주간/월간 통계용 배열
    @Published public private(set) var weekly: [WeeklySleep] = []
    /// 표시할 통계 기간 텍스트 ("시작일 ~ 종료일")
    @Published public private(set) var periodText: String = ""
    /// 평균 수면 시간 텍스트 ("Xh Ym")
    @Published public private(set) var averageText: String = ""
    /// 평균 수면 시간에 대한 코멘트
    @Published public private(set) var averageComment: String = ""
    
    // Combine 구독 취소를 관리하는 Set
    private var cancellables = Set<AnyCancellable>()
    // 네트워크 요청을 처리하는 Moya 프로바이더 (DI 가능)
    private let provider: MoyaProvider<ProfileRouter>

    // MARK: - Init

    /// 초기화: 프로바이더 주입 및 주간 통계 자동 Fetch
    /// - Parameter provider: 네트워크 프로바이더 (기본: 테스트 모드 프로바이더)
    init(provider: MoyaProvider<ProfileRouter> = APIManager.shared.testProvider(for: ProfileRouter.self)) {
        self.provider = provider
        fetchWeekly() // 초기 로드시 주간 통계 데이터를 가져옵니다
    }

    // MARK: - Fetch Methods

    /// 주간 통계 데이터 요청
    public func fetchWeekly() {
        provider.fetchWeeklyStats()
            .receive(on: DispatchQueue.main) // UI 업데이트는 메인 스레드에서
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(err) = completion {
                        // 에러 발생 시 콘솔 출력
                        print("Error fetching weekly stats:", err)
                    }
                },
                receiveValue: { [weak self] resp in
                    // 응답 수신 후 데이터 갱신
                    self?.updateWeekly(with: resp)
                }
            )
            .store(in: &cancellables)
    }

    /// 월간 통계 데이터 요청
    public func fetchMonthly() {
        provider.fetchMonthlyStats()
            .receive(on: DispatchQueue.main) // UI 업데이트는 메인 스레드에서
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(err) = completion {
                        // 에러 발생 시 콘솔 출력
                        print("Error fetching monthly stats:", err)
                    }
                },
                receiveValue: { [weak self] resp in
                    // 응답 수신 후 데이터 갱신
                    self?.updateMonthly(with: resp)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Update Helpers

    /// WeeklySleepResponse로부터 뷰모델 프로퍼티를 업데이트합니다
    /// - Parameter response: 주간 통계 응답 모델
    public func updateWeekly(with response: WeeklySleepResponse) {
        let model = WeeklySleepStatsModel(from: response)

        // 일별 데이터 설정
        daily = model.daily

        // 기간 텍스트 포맷 설정
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        periodText = "\(df.string(from: model.startDate)) ~ \(df.string(from: model.endDate))"

        // 평균 수면 시간 텍스트 설정
        let h = model.averageHours ?? 0
        let m = model.averageMinutes ?? 0
        averageText = "\(h)h \(m)m"

        // 평균 수면 시간에 대한 코멘트 설정
        averageComment = model.comment
    }

    /// MonthlySleepResponse로부터 뷰모델 프로퍼티를 업데이트합니다
    /// - Parameter response: 월간 통계 응답 모델
    public func updateMonthly(with response: MonthlySleepResponse) {
        let model = MonthlySleepStatsModel(from: response)

        // 주간/월간 데이터 설정
        weekly = model.weekly

        // 기간 텍스트 포맷 설정
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        periodText = "\(df.string(from: model.startDate)) ~ \(df.string(from: model.endDate))"

        // 평균 수면 시간 텍스트 설정
        let h = model.averageHours ?? 0
        let m = model.averageMinutes ?? 0
        averageText = "\(h)h \(m)m"

        // 평균 수면 시간에 대한 코멘트 설정
        averageComment = model.comment
    }
}
