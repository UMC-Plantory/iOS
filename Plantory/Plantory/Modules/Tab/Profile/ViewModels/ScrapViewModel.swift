//
//  ScrapViewModel.swift
//  Plantory
//
//  Created by 주민영 on 8/22/25.
//

import Foundation
import Combine
import Moya

@MainActor
class ScrapViewModel: ObservableObject {
    
    // MARK: - Toast
    
    @Published var toast: CustomToast? = nil

    @Published var diaries: [DiaryFilterSummary] = []
    
    @Published var isLoading: Bool = false //현재 데이터를 불러오는 중인지 여부
    @Published var hasNext: Bool = true
  
    // MARK: - State
    
    @Published var cursor: String? = nil

    // MARK: - 의존성 주입 및 비동기 처리
    
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()

    // MARK: - 초기화
 
    init(container: DIContainer) {
        self.container = container
    }
 
    //MARK: - 함수
    
    // 스크립 조회 API 호출
    public func fetchFilteredDiaries(sort: SortOrder) async {
        guard hasNext, !isLoading else { return }
        isLoading = true
        
        container.useCaseService.profileService.scrap(sort: sort, cursor: cursor)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let failure) = completion {
                    self?.toast = CustomToast(
                        title: "스크랩 조회 오류",
                        message: "\(failure.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("필터 조회 오류: \(failure)")
                }
            }, receiveValue: { [weak self] result in
                self?.diaries.append(contentsOf: result.diaries)
                self?.cursor = result.nextCursor
                self?.hasNext = result.hasNext
            })
            .store(in: &cancellables)
    }
}
