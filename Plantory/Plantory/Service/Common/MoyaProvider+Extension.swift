//
//  MoyaProvider+Extension.swift
//  Plantory
//
//  Created by 주민영 on 8/4/25.
//

import SwiftUI
import Combine
import Moya

extension MoyaProvider {
    func requestResult<T: Decodable>(
        _ target: Target,
        type: T.Type
    ) -> AnyPublisher<T, APIError> {
        return self.requestPublisher(target)
            .map(APIResponse<T>.self)
            .tryMap { response in
                if response.isSuccess {
                    if let result = response.result {
                        /// API 요청에 성공한 경우 -> 응답 결과 리턴
                        return result
                    } else {
                        /// 응답 결과 디코딩에 실패함 -> 디코딩 에러 리턴
                        throw APIError.decodingError
                    }
                } else {
                    /// API 요청에 성공했으나, 백엔드 서버 에러가 발생한 경우 -> 서버 에러 리턴
                    throw APIError.serverError(code: response.code, message: response.message)
                }
            }
            .mapError { error in
                /// API 요청에 실패함 -> 에러 리턴
                if let moya = error as? MoyaError {
                    return .moyaError(moya)
                } else if let api = error as? APIError {
                    return api
                } else {
                    return .unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
