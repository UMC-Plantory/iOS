import SwiftUI
import Combine

final class MyPageStatsViewModel: ObservableObject {
    @Published var response: ProfileStatsResponse?
    @Published private(set) var stats: [Stat] = []

    // 뷰에서 바로 쓸 표시용 프로퍼티
    @Published private(set) var nicknameText: String = ""
    @Published private(set) var userCustomIdText: String = ""
    @Published private(set) var profileImageURL: URL? = nil

    // 로그아웃 상태
    @Published private(set) var isLoggingOut = false
    @Published private(set) var didLogout = false
    @Published private(set) var logoutErrorMessage: String?
    
    // MARK: - 로딩
    
    @Published var isLoading = false

    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private let sessionManager: SessionManager

    init(container: DIContainer, sessionManager: SessionManager) {
        self.container = container
        self.sessionManager = sessionManager
        fetch()
    }

    func fetch() {
        self.isLoading = true
        
        container.useCaseService.profileService
            .fetchProfileStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
            } receiveValue: { [weak self] r in
                guard let self else { return }
                self.response = r
                self.applyDisplayFields(from: r)
                self.stats = Self.makeStats(from: r)
                self.isLoading = false
            }
            .store(in: &cancellables)
    }

    /// 로그아웃 API
    func logout() {
        guard !isLoggingOut else { return }
        self.isLoading = true
        isLoggingOut = true
        logoutErrorMessage = nil
        didLogout = false

        container.useCaseService.profileService
            .logout()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoggingOut = false
                if case let .failure(err) = completion {
                    self.logoutErrorMessage = err.localizedDescription
                    self.isLoading = false
                }
            } receiveValue: { [weak self] _ in
                self?.didLogout = true
                self?.isLoading = false
                
                self?.container.navigationRouter.reset()
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.sessionManager.logout()
                }
            }
            .store(in: &cancellables)
    }


    // avgSleepTime(분) → "6h 53m"
    private static func makeStats(from r: ProfileStatsResponse) -> [Stat] {
        let h = r.avgSleepTime / 60
        let m = r.avgSleepTime % 60
        let avg = "\(h)h \(m)m"

        return [
            Stat(value: "\(r.continuousRecordCnt)일", label: "연속 기록"),
            Stat(value: "\(r.totalRecordCnt)개",     label: "누적 감정 기록 횟수"),
            Stat(value: avg,                        label: "평균 수면 시간"),
            Stat(value: "\(r.totalBloomCnt)개",     label: "피어난 꽃의 수")
        ]
    }

    private func applyDisplayFields(from r: ProfileStatsResponse) {
        nicknameText = r.nickname
        userCustomIdText = r.userCustomId
        profileImageURL = URL(string: r.profileImgUrl.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
