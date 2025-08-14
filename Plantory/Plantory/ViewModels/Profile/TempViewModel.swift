import Foundation
import Moya
import Combine
import CombineMoya

public class TempViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var diaries: [Diary] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    let container: DIContainer
    
    // MARK: - Init
    init(container: DIContainer) {
        self.container = container
        fetchTemp()
    }

    // MARK: - API Fetch
    public func fetchTemp(sort: SortOrder = .latest) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.profileService
            .fetchTemp(sort: sort)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] diaries in
                self?.handleTemp(diaries)
            }
            .store(in: &cancellables)
    }
    
    public func moveToTrash(ids: [Int], sort: SortOrder = .latest) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.profileService
            .patchWaste(diaryIds: ids)
            .map { _ in () }
            .flatMap { [weak self] _ -> AnyPublisher<[Diary], APIError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.container.useCaseService.profileService.fetchTemp(sort: sort)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] diaries in
                self?.handleTemp(diaries) // 화면 갱신
            }
            .store(in: &cancellables)
    }




    // MARK: - Handlers
    private func handleTemp(_ diaries: [Diary]) {
        self.diaries = diaries
    }

    // MARK: - Cell ViewModels
    public struct DiaryCellViewModel: Identifiable {
        public let id: Int
        public let title: String
        public let dateText: String
    }

    public var cellViewModels: [DiaryCellViewModel] {
        diaries.map { d in
            DiaryCellViewModel(
                id: d.id,
                title: d.title,
                // 서버에서 "YYYY-MM-DD"로 오므로 점 포맷으로만 교체
                dateText: d.date.replacingOccurrences(of: "-", with: ".")
            )
        }
    }
}
