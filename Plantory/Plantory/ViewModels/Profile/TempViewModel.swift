//
//  TempViewModel.swift
//  Plantory
//
//  Created by 이효주 on 7/14/25.
//

import Foundation
import Moya
import Combine
import CombineMoya

public class TempViewModel: ObservableObject {
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
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    
    // MARK: - Init
    init(
        provider: MoyaProvider<ProfileRouter> = APIManager.shared.testProvider(for: ProfileRouter.self),
        container: DIContainer
    ) {
        self.provider = provider
        self.container = container
        fetchTemp()
    }

    // MARK: - API Fetch
    /// 임시 일기 목록을 서버에서 가져옵니다.
    /// - Parameter sort: `.oldest` 또는 `.latest`
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
    
    /// 선택된 일기를 휴지통으로 이동(PATCH)하고, 성공 시 로컬 배열에서 제거
    public func moveToTrash(ids: [Int]) {
        isLoading = true
        errorMessage = nil

        container.useCaseService.profileService
            .patchWaste(diaryIds: ids)               // PATCH /diary/waste 호출
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                if response.isSuccess {
                    // 실제로 삭제된 것처럼 로컬 상태에서 제거
                    self.diaries.removeAll { ids.contains($0.id) }
                } else {
                    self.errorMessage = response.message
                }
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
