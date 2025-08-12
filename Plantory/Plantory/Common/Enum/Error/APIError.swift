//
//  ChatError.swift
//  Plantory
//
//  Created by 주민영 on 7/31/25.
//

import Foundation
import Moya

enum APIError: Error {
    case decodingError
    case moyaError(MoyaError)
    case serverError(code: String, message: String)
    case unauthorized
    case forbidden
    case notFound
    case unknown
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .decodingError:
            return "디코딩에 실패했어요."
        case .moyaError(let error):
            return error.localizedDescription
        case .serverError(_, let message):
            return message
        case .unauthorized:
            return "로그인이 필요해요."
        case .forbidden:
            return "접근 권한이 없어요."
        case .notFound:
            return "요청한 리소스를 찾을 수 없어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        }
    }
}
