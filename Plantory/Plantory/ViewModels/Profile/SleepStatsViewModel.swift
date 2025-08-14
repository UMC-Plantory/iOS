import Foundation
import Combine
import Moya
import CombineMoya

/// 뷰모델: 주간 및 월간 수면 통계 데이터를 처리하고 뷰에 제공하는 ObservableObject
public class SleepStatsViewModel: ObservableObject {
    // MARK: - Published Properties (뷰에 바인딩할 데이터)
    /// 일별 수면 데이터를 담는 배열 (주간)
    @Published public private(set) var daily: [DailySleep] = []
    /// 주별 수면 데이터를 담는 배열 (월간)
    @Published public private(set) var monthly: [WeeklyInterval] = []
    /// 오늘 요일을 한글로 표시 ("일", "월", ...)
    @Published public private(set) var todayWeekday: String = ""
    /// 통계 기간을 "yyyy.MM.dd ~ yyyy.MM.dd" 형식으로 표시
    @Published public private(set) var periodText: String = ""
    /// 평균 수면 시간을 "Xh Ym" 형식으로 표시
    @Published public private(set) var averageText: String = ""
    /// 평균 수면 시간에 따른 코멘트 (SleepStats 프로토콜의 comment)
    @Published public private(set) var averageComment: String = ""
    @Published public private(set) var comment: String = ""
    // 24시간 대비 평균 수면 비율
    @Published public private(set) var progress: Double = 0
    
    // MARK: - Dependencies (의존성 주입)
    /// 날짜 계산에 사용할 캘린더 (테스트 용도 DI)
    private let calendar: Calendar
    /// 오늘 날짜 (테스트 용도 DI)
    private let today: Date
    /// Combine 구독을 관리하는 세트
    private var cancellables = Set<AnyCancellable>()
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer


    // MARK: - Formatters & Mappings
    /// 기간 텍스트 생성을 위한 DateFormatter ("2025년 6월 8일" 포맷)
    private static let periodFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")      // 한국어 로케일
        df.dateFormat = "yyyy년 M월 d일"             // 연, 월, 일을 글자로 표시
        return df
    }()
    /// Swift의 .weekday 결과(1~7)를 한글 요일로 매핑하기 위한 배열
    private static let koreanWeekdays = ["일","월","화","수","목","금","토"]

    // MARK: - Init (초기화)
    /**
     의존성 주입을 통해 테스트 및 확장에 용이하도록 구성.
     - Parameters:
       - provider: 네트워크 프로바이더 (기본값: APIManager.shared.testProvider)
       - calendar: 날짜 계산용 캘린더 (기본값: .current)
       - today: 기준이 될 오늘 날짜 (기본값: Date())
     */
    init(
        calendar: Calendar = .current,
        today: Date = Date(),
        container: DIContainer
    ) {
        self.calendar = calendar
        self.today = today
        self.container = container
        // 초기 로드 시 주간 통계 가져오기
        fetchWeekly()
    }

    // MARK: - API Fetch (데이터 요청)
    /// 주간 통계 데이터 요청 및 처리 흐름
    public func fetchWeekly() {
        container.useCaseService.profileService.fetchWeeklyStats()
            .receive(on: DispatchQueue.main) // 메인 스레드에서 결과 처리
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        // 네트워크 오류 처리 (개발 편의를 위해 print 사용)
                        print("Error fetching weekly stats:", error)
                    }
                },
                receiveValue: { [weak self] response in
                    // 성공적으로 받아온 응답을 핸들러로 전달
                    self?.handleWeekly(response)
                }
            )
            .store(in: &cancellables)
    }

    /// 월간 통계 데이터 요청 및 처리 흐름
    public func fetchMonthly() {
        container.useCaseService.profileService.fetchMonthlyStats()
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

    // MARK: - Handlers (응답 처리)
    /**
     주간 통계 응답 처리 및 Published 프로퍼티 업데이트
     - Parameters:
       - response: 서버로부터 받은 WeeklySleepResponse 객체
     */
    private func handleWeekly(_ response: WeeklySleepResponse) {
        // 1. DTO → 뷰 모델 변환
        let model = WeeklySleepStatsModel(from: response, calendar: calendar)
        daily = model.daily

        // 2. 오늘 요일 한글로 변환 (Calendar.weekday: 1=일요일 ~ 7=토요일)
        let idx = calendar.component(.weekday, from: today) - 1
        todayWeekday = Self.koreanWeekdays[idx]

        // 3. 기간 텍스트 설정 ("시작일 ~ 종료일")
        periodText = "\(Self.periodFormatter.string(from: model.startDate)) ~ " +
                     "\(Self.periodFormatter.string(from: model.endDate))"

        // 4. 평균 수면 시간 텍스트 및 코멘트 설정
        averageText    = "\(model.averageHours ?? 0)h \(model.averageMinutes ?? 0)m"
        averageComment = model.comment
        comment = "주간 평균 수면 시간"
        progress = model.totalHours / 24
    }

    /**
     월간 통계 응답 처리 및 Published 프로퍼티 업데이트
     - Parameters:
       - response: 서버로부터 받은 MonthlySleepResponse 객체
     */
    private func handleMonthly(_ response: MonthlySleepResponse) {
        // 1. DTO → 뷰 모델 변환
        let model = MonthlySleepStatsModel(from: response)
        monthly = model.weekly

        // 2. 기간 텍스트 설정
        periodText = "\(Self.periodFormatter.string(from: model.startDate)) ~ " +
                     "\(Self.periodFormatter.string(from: model.endDate))"

        // 3. 평균 수면 시간 텍스트 및 코멘트 설정
        averageText    = "\(model.averageHours ?? 0)h \(model.averageMinutes ?? 0)m"
        averageComment = model.comment
        comment = "월간 평균 수면 시간"
        
        progress = model.totalHours / 24
    }
}
