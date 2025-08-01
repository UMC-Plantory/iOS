//
//  ChatError.swift
//  Plantory
//
//  Created by 주민영 on 7/31/25.
//

import Foundation
import Moya

enum ChatError: Error, LocalizedError {
    case moyaError(MoyaError)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .moyaError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError:
            return "디코딩 오류 발생"
        case .unknown:
            return "알 수 없는 오류 발생"
        }
    }
}
