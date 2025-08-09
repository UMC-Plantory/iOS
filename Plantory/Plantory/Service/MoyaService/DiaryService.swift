//
//  DiaryService.swift
//  Plantory
//
//  Created by 박병선 on 8/2/25.
//
// 실제 요청 함수들 모음
import Foundation
import Moya

final class DiaryService {
    
    private let provider = MoyaProvider<DiaryAPI>()

    
    /// 일기 스크랩
    func scrapDiary(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.scrapDiary(id: id)) { result in
            switch result {
            case .success(let response):
                if (200...299).contains(response.statusCode) {
                    print("스크랩 요청 성공, 상태코드 : \(response.statusCode)")
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "", code: response.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "스크랩 실패"
                    ])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
                print("요청실패: \(error.localizedDescription)")
            }
        }
    }

    /// 일기 스크랩 취소
    func unscrapDiary(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.unScrapDiary(id: id)) { result in
            switch result {
            case .success(let response):
                if (200...299).contains(response.statusCode) {
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "", code: response.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "스크랩 취소 실패"
                    ])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    
    
}

