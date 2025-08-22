//
//  DiaryService.swift
//  Plantory
//
//  Created by 박병선 on 8/2/25.
//

import Foundation
import Combine
import Moya
import CombineMoya

protocol DiaryServiceProtocol {

    // 개별 일기 조회 (GET /diaries/{id})
    func fetchDiary(id: Int) -> AnyPublisher<DiarySummary, APIError>

    // 일기 스크랩 / 스크랩 취소 (PATCH /diaries/{id}/scrap-status/{on|off})
    func scrapOn(id: Int)  -> AnyPublisher<StatusResponseOnly, APIError>
    func scrapOff(id: Int) -> AnyPublisher<StatusResponseOnly, APIError>

    // 일기 수정 (PATCH /diaries/{id})
    func editDiary(id: Int, data: DiaryEditRequest) -> AnyPublisher<DiaryDetail, APIError>

    // 일기 휴지통 이동 (PATCH /diaries/waste-status)
    func moveToTrash(ids: [Int]) -> AnyPublisher<StatusResponseOnly, APIError>
    
    //일기 영구 삭제
    func deletePermanently(ids: [Int]) -> AnyPublisher<StatusResponseOnly, APIError>
    
    // 일기 임시 보관/복원 토글 (PATCH /diaries/temp-status)
    func updateTempStatus(ids: [Int]) -> AnyPublisher<StatusResponseOnly, APIError>

    // 일기 검색 (GET /diaries/search?...)
    func searchDiary(_ req: DiarySearchRequest) -> AnyPublisher<DiarySearchResult, APIError>

    // 일기 목록 필터 조회 (GET /diaries/filter?...)
    func fetchFilteredDiaries(_ req: DiaryFilterRequest) -> AnyPublisher<DiaryFilterResult, APIError>
}


///DiaryRouter 사용하는 서비스
final class DiaryService: DiaryServiceProtocol {
    /// MoyaProvider를 통해 API 요청을 전송
    let provider: MoyaProvider<DiaryRouter>

    // MARK: - Initializer

    /// 기본 initializer - verbose 로그 플러그인을 포함한 provider 생성
    init(provider: MoyaProvider<DiaryRouter> = APIManager.shared.createProvider(for: DiaryRouter.self)) {
        self.provider = provider
    }

    // MARK: - 단일 일기 조회 (GET /diaries/{id})
    func fetchDiary(id: Int) -> AnyPublisher<DiarySummary, APIError> {
        provider.requestResult(.fetchDiary(id: id), type: DiarySummary.self)
    }

    // MARK: - 스크랩 (PATCH /diaries/{id}/scrap-status/on)
    func scrapOn(id: Int) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.scrapOn(id: id))
    }

    // MARK: - 스크랩 취소 (PATCH /diaries/{id}/scrap-status/off)
    func scrapOff(id: Int) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.scrapOff(id: id))
    }

    // MARK: - 일기 수정 (PATCH /diaries/{id})
    func editDiary(id: Int, data: DiaryEditRequest) -> AnyPublisher<DiaryDetail, APIError> {
        provider.requestResult(.editDiary(id: id, data: data), type: DiaryDetail.self)
    }

    // MARK: - 휴지통 이동 (PATCH /diaries/waste-status)
    func moveToTrash(ids: [Int]) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.moveToTrash(ids: ids))
    }

    //MARK: - 일기 영구삭제
    func deletePermanently(ids: [Int]) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.deletePermanently(ids: ids))
    }

    // MARK: - 임시 보관/복원 토글 (PATCH /diaries/temp-status)
    func updateTempStatus(ids: [Int]) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.tempStatus(ids: ids))
    }

    // MARK: - 일기 검색 (GET /diaries/search?...)
    func searchDiary(_ req: DiarySearchRequest) -> AnyPublisher<DiarySearchResult, APIError> {
        provider.requestResult(.searchDiary(req), type: DiarySearchResult.self)
    }

    // MARK: - 일기 목록 필터 (GET /diaries/filter?...)
    func fetchFilteredDiaries(_ req: DiaryFilterRequest) -> AnyPublisher<DiaryFilterResult, APIError> {
        provider.requestResult(.fetchFilteredDiaries(filterData: req), type: DiaryFilterResult.self)
    }
}
