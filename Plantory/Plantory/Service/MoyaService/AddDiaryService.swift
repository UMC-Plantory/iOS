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
    /// 해당 날짜 정식 저장 일기 존재 여부
    func checkDiaryExist(diaryDate: String) -> AnyPublisher<DiaryExistResult, APIError>
    /// 해당 날짜 임시저장 일기 가져오기
    func fetchTempDiary(diaryDate: String) -> AnyPublisher<TempDiaryResponse, APIError>
    /// 해당 날짜 임시저장 존재 여부
    func checkTempExist(diaryDate: String) -> AnyPublisher<DiaryExistResult, APIError>
}

/// 일기 생성 서비스
final class AddDiaryService: AddDiaryServiceProtocol {

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
    
    /// 이미 해당 날짜 일기 존재 여부
    func checkDiaryExist(diaryDate: String) -> AnyPublisher<DiaryExistResult, APIError> {
        provider.requestResult(.checkExist(diaryDate: diaryDate), type: DiaryExistResult.self)
    }

    /// 서버 보관 TEMP 불러오기
    func fetchTempDiary(diaryDate: String) -> AnyPublisher<TempDiaryResponse, APIError> {
        provider.requestResult(.getTemp(diaryDate: diaryDate), type: TempDiaryResponse.self)
    }
    
    /// TEMP 존재 여부
    func checkTempExist(diaryDate: String) -> AnyPublisher<DiaryExistResult, APIError> {
        provider.requestResult(.checkTempExist(diaryDate: diaryDate), type: DiaryExistResult.self)
    }
}
