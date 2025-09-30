//
//  AddDiaryService.swift
//  Plantory
//
//  Created by 주민영 on 8/15/25.
//

import Foundation
import Combine
import Moya

/// 일기 생성 서비스 프로토콜
protocol AddDiaryServicieProtocol {
    /// 새 일기 등록 (NORMAL/TEMP 공통)
    func createDiary(_ request: AddDiaryRequest) -> AnyPublisher<AddDiaryResponse, APIError>
    func checkDiaryExist(date: String) -> AnyPublisher<DiaryExistResult, APIError>
    func fetchTempDiary(date: String) -> AnyPublisher<TempDiaryResponse, APIError>
    func checkTempExist(date: String) -> AnyPublisher<DiaryExistResult, APIError>
}

/// 일기 생성 서비스
final class AddDiaryService: AddDiaryServicieProtocol {

    private let provider: MoyaProvider<AddDiaryRouter>

    /// 기본 생성자
    /// - note: 토큰/로깅 등 공통 플러그인은 APIManager에서 구성했다고 가정
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
    
    // 이미 해당 날짜 일기 존재 여부
    func checkDiaryExist(date: String) -> AnyPublisher<DiaryExistResult, APIError> {
        provider.requestResult(.checkExist(date: date), type: DiaryExistResult.self)
    }

    // 서버 보관 TEMP 불러오기
    func fetchTempDiary(date: String) -> AnyPublisher<TempDiaryResponse, APIError> {
        provider.requestResult(.getTemp(date: date), type: TempDiaryResponse.self)
    }
    
    func checkTempExist(date: String) -> AnyPublisher<DiaryExistResult, APIError> {
        provider.requestResult(.checkTempExist(date: date), type: DiaryExistResult.self)
    }
}
