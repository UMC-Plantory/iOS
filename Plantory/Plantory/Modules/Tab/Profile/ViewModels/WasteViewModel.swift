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
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer

    // MARK: - Init
    /// 기본적으로 테스트용 stub provider 사용
    init(
        container: DIContainer
    ) {
        self.container = container
        fetchWaste()
    }

    // MARK: - API Fetch
    /// 휴지통 일기 목록을 서버에서 가져옵니다.
    /// - Parameter sort: `.latest` 또는 `.oldest`
    public func fetchWaste(sort: SortOrder = .latest) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.profileService
            .fetchWaste(sort: sort)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] diaries in
                self?.handleWaste(diaries)
            }
            .store(in: &cancellables)
    }
    
    /// 선택된 일기를 영구 삭제하고, 성공 시 로컬 배열에서 제거
    /// 선택된 일기를 영구 삭제합니다. (휴지통 → 완전 삭제)
    // 삭제 (휴지통 → 완전 삭제)
    public func deleteForever(ids: [Int], sort: SortOrder = .latest) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.profileService
            .deleteWaste(diaryIds: ids)
            .map { _ in () }
            .flatMap { [weak self] _ -> AnyPublisher<[Diary], APIError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.container.useCaseService.profileService.fetchWaste(sort: sort)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] diaries in
                self?.handleWaste(diaries)
            }
            .store(in: &cancellables)
    }



    // 복원
    /// 선택된 일기를 복원합니다. (휴지통 → 임시보관함)
    // 복원 (휴지통 → 임시보관함)
    public func restoreWaste(ids: [Int], sort: SortOrder = .latest) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.profileService
            .restoreWaste(diaryIds: ids)
            .map { _ in () }
            .flatMap { [weak self] _ -> AnyPublisher<[Diary], APIError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.container.useCaseService.profileService.fetchWaste(sort: sort)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] diaries in
                self?.handleWaste(diaries)
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
