import Foundation
import Moya
import Combine
import CombineMoya

/// 휴지통 일기 목록을 서버에서 가져오는 ViewModel
public class WasteViewModel: ObservableObject {
    // MARK: - Date Formatter
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        return df
    }()

    // MARK: - Published Properties
    @Published public private(set) var diaries: [Diary] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    let container: DIContainer

    // 단일 리프레시 파이프라인용
    private let refreshTrigger = PassthroughSubject<Void, Never>()
    private var lastSort: SortOrder = .latest

    // MARK: - Init
    /// 기본적으로 테스트용 stub provider 사용
    init(container: DIContainer) {
        self.container = container
        bindRefreshPipeline() // 파이프라인 먼저 연결
        fetchWaste()          // 그 다음 트리거
    }

    // MARK: - Refresh Pipeline
    private func bindRefreshPipeline() {
        refreshTrigger
            .map { [weak self] in
                guard let self else {
                    return Empty<[Diary], APIError>().eraseToAnyPublisher()
                }
                return self.container.useCaseService.profileService
                    .fetchWaste(sort: self.lastSort) // AnyPublisher<[Diary], APIError>
            }
            .switchToLatest()
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.isLoading = true
                    self?.errorMessage = nil
                },
                receiveCancel: { [weak self] in
                    // switchToLatest로 취소될 때도 로딩 OFF
                    self?.isLoading = false
                }
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // 정상 종료/에러 때도 로딩 OFF
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] diaries in
                // 값 도착 시에도 바로 로딩 OFF (cancel/complete 누락 방지)
                self?.isLoading = false
                self?.handleWaste(diaries)
            }
            .store(in: &cancellables)
    }


    private func triggerRefresh() {
        refreshTrigger.send(())
    }

    // MARK: - API Fetch
    /// 휴지통 일기 목록을 서버에서 가져옵니다.
    /// - Parameter sort: `.latest` 또는 `.oldest`
    public func fetchWaste(sort: SortOrder = .latest) {
        lastSort = sort
        triggerRefresh()
    }

    /// 선택된 일기를 영구 삭제합니다. (휴지통 → 완전 삭제)
    public func deleteForever(ids: [Int], sort: SortOrder = .latest) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.profileService
            .deleteWaste(diaryIds: ids)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                // 낙관적 업데이트: 화면 즉시 반영
                self.diaries.removeAll { ids.contains($0.id) }
                // 최신 상태 동기화 (이전 fetch는 switchToLatest로 자동 취소됨)
                self.lastSort = sort
                self.triggerRefresh()
            }
            .store(in: &cancellables)
    }

    /// 선택된 일기를 복원합니다. (휴지통 → 임시보관함)
    public func restoreWaste(ids: [Int], sort: SortOrder = .latest) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.profileService
            .restoreWaste(diaryIds: ids)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                // 휴지통 화면에서는 복원된 항목을 즉시 제거
                self.diaries.removeAll { ids.contains($0.id) }
                self.lastSort = sort
                self.triggerRefresh()
            }
            .store(in: &cancellables)
    }

    // MARK: - Handlers
    private func handleWaste(_ diaries: [Diary]) {
        self.diaries = diaries
    }

    // MARK: - Cell ViewModels
    public struct DiaryCellViewModel: Identifiable {
        public let id: Int
        public let title: String
        public let dateText: String
    }

    /// 뷰에서 사용할 CellViewModel 배열
    public var cellViewModels: [DiaryCellViewModel] {
        diaries.map { diary in
            DiaryCellViewModel(
                id: diary.id,
                title: diary.title,
                dateText: diary.date.replacingOccurrences(of: "-", with: ".")
            )
        }
    }
}
