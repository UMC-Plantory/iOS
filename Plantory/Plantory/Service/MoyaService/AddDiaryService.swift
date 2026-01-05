//
//  AddDiaryService.swift
//  Plantory
//
//  Created by 주민영 on 8/15/25.
//

import Foundation
import Combine
import Moya


/// 일기 생성/조회 서비스 프로토콜
protocol AddDiaryServiceProtocol {
    /// 새 일기 등록 (NORMAL/TEMP 공통)
    func createDiary(_ request: AddDiaryRequest) -> AnyPublisher<AddDiaryResponse, APIError>
    /// 특정 날짜에 정식 저장 일기 존재 여부 조회
    func fetchNormalDiaryStatus(date: String) -> AnyPublisher<DiaryExistResult, APIError>
    /// 특정 날짜에 임시 저장 일기 존재 여부 조회
    func fetchTempDiaryStatus(date: String) -> AnyPublisher<DiaryExistResult, APIError>
    /// 임시 저장된 일기 상세 조회
    func fetchTempDiary(id: Int) -> AnyPublisher<TempDiaryResult, APIError>
}

/// 일기 생성 서비스
final class AddDiaryService: AddDiaryServiceProtocol {

    private let provider: MoyaProvider<AddDiaryRouter>

    /// 기본 생성자
    init(provider: MoyaProvider<AddDiaryRouter> = APIManager.shared.createProvider(for: AddDiaryRouter.self)) {
        self.provider = provider
    }

    /// 스텁 전용 생성자(미리보기/유닛테스트)
    convenience init(stubbed: Bool) {
        if stubbed {
            let provider = MoyaProvider<AddDiaryRouter>(stubClosure: MoyaProvider.immediatelyStub)
            self.init(provider: provider)
        } else {
            self.init()
        }
    }

    // MARK: - API

    func createDiary(_ request: AddDiaryRequest) -> AnyPublisher<AddDiaryResponse, APIError> {
        provider.requestResult(.create(body: request), type: AddDiaryResponse.self)
    }
    
    func fetchNormalDiaryStatus(date: String) -> AnyPublisher<DiaryExistResult, APIError> {
        provider.requestResult(.fetchNormalDiaryStatus(date: date), type: DiaryExistResult.self)
    }
    
    func fetchTempDiaryStatus(date: String) -> AnyPublisher<DiaryExistResult, APIError> {
        provider.requestResult(.fetchTempDiaryStatus(date: date), type: DiaryExistResult.self)
    }
    
    func fetchTempDiary(id: Int) -> AnyPublisher<TempDiaryResult, APIError> {
        provider.requestResult(.fetchTempDiary(id: id), type: TempDiaryResult.self)
    }
}
