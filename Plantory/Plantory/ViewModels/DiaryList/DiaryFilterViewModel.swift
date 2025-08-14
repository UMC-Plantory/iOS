//
//  DiaryFilterViewModel.swift
//  Plantory
//
//  Created by 박병선 on 8/9/25.
// 관리해야 할 API: 필터링
import Foundation
import Combine
import Moya
import SwiftUI

class DiaryFilterViewModel: ObservableObject {
    @Published var diaries: [DiarySummary] = []
    @Published var hasNext: Bool = false
    @Published var nextCursor: String? = nil
    @Published var isLoading: Bool = false // 중복/결합 요청 방지(isLoading으로 가드)
    @Published var errorMessage: String? // 에러처리 표면화
    
    // MARK: - Filter State
       @Published var sort: String = "latest"      // "latest" | "oldest"
       @Published var from: String? = nil          // "YYYY-MM"
       @Published var to: String? = nil            // "YYYY-MM"
       @Published var emotion: Emotion = .all
       @Published var size: Int = 15
    
    private var cursor: String? = nil
    private let diaryService : DiaryServiceProtocol
    private let calendar = Calendar.current
    private let currentDate = Date() //현재 날짜 표기
    
    var currentFilter = DiaryFilterRequest(sort: .latest, from: nil, to: nil, emotion: .all, cursor: nil, size: 10)
    //일기 필터 요청을 주입 받음
   
    // MARK: - 의존성 주입 및 비동기 처리
    
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - 초기화
    init(
            diaryService: DiaryServiceProtocol = DiaryService(),
            container: DIContainer
        ) {
            self.diaryService = diaryService
            self.container = container
        }
    
    //MARK: - 함수
    
    //미래의 달(월)을 식별하는 함수
    func isFutureMonth(year: Int, month: Int) -> Bool {
        guard let compareDate = calendar.date(from: DateComponents(year: year, month: month)) else {
            return false
        }
        return compareDate > currentDate
    }
    

    // MARK: - API
    /// 일기 목록 필터 조회 (첫 페이지)
        public func fetchFilteredDiaries(_ request: DiaryFilterRequest) {
            isLoading = true

            diaryService.fetchFilteredDiaries(request)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let failure) = completion {
                        print("필터 조회 오류: \(failure)")
                        self?.isLoading = false
                    }
                }, receiveValue: { [weak self] result in
                    // result.diaries: [DiarySummary]
                    self?.diaries = result.diaries
                    self?.cursor = result.nextCursor
                    self?.hasNext = result.hasNext
                    self?.isLoading = false
                })
                .store(in: &cancellables)
        }
    
    ///다음 페이지(커서 페이징)
    public func fetchMore(with base: DiaryFilterRequest) {
           guard hasNext, !isLoading else { return }
           isLoading = true

           let nextReq = DiaryFilterRequest(
               sort: base.sort,
               from: base.from,
               to: base.to,
               emotion: base.emotion,
               cursor: cursor,          // ← 마지막 커서로 다음 페이지 요청
               size: base.size
           )

           diaryService.fetchFilteredDiaries(nextReq)
               .receive(on: DispatchQueue.main)
               .sink(receiveCompletion: { [weak self] completion in
                   if case .failure(let failure) = completion {
                       print("다음 페이지 오류: \(failure)")
                       self?.isLoading = false
                   }
               }, receiveValue: { [weak self] result in
                   self?.diaries += result.diaries
                   self?.cursor = result.nextCursor
                   self?.hasNext = result.hasNext
                   self?.isLoading = false
               })
               .store(in: &cancellables)
       }

    
}
