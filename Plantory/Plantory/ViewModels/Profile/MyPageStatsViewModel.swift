import Foundation
import Combine

final class MyPageStatsViewModel: ObservableObject {
    @Published var response: ProfileStatsResponse?
    @Published private(set) var stats: [Stat] = []

    // 뷰에서 바로 쓸 표시용 프로퍼티 (가공/포맷 끝난 값)
    @Published private(set) var nicknameText: String = ""
    @Published private(set) var userCustomIdText: String = ""
    @Published private(set) var profileImageURL: URL? = nil

    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer) {
        self.container = container
        fetch()
    }

    func fetch() {
        container.useCaseService.profileService
            .fetchProfileStats()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] r in
                guard let self else { return }
                self.response = r
                self.applyDisplayFields(from: r)
                self.stats = Self.makeStats(from: r)
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

    // 닉네임/커스텀ID/프로필이미지 URL 가공은 전부 여기서
    private func applyDisplayFields(from r: ProfileStatsResponse) {
        nicknameText = r.nickname
        userCustomIdText = r.userCustomId
        profileImageURL = URL(string: r.profileImgUrl.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
