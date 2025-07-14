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
    private let provider: MoyaProvider<ProfileRouter>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    /// 기본적으로 테스트용 stub provider 사용
    init(
        provider: MoyaProvider<ProfileRouter> = APIManager.shared.testProvider(for: ProfileRouter.self)
    ) {
        self.provider = provider
        fetchWaste()
    }

    // MARK: - API Fetch
    /// 휴지통 일기 목록을 서버에서 가져옵니다.
    /// - Parameter sort: `.latest` 또는 `.oldest`
    public func fetchWaste(sort: SortOrder = .latest) {
        isLoading = true
        errorMessage = nil

        provider
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
                dateText: Self.dateFormatter.string(from: diary.date)
            )
        }
    }
}
