//
//  ImageRouter.swift
//  Plantory
//
//  Created by 주민영 on 8/12/25.
//

import Foundation
import Moya

enum ImageRouter {
    case generatePresignedURL(request: PresignedRequest) // Presigned URL 발급
    case putImage(presignedURL: String, data: Data) // 이미지 업로드
}

extension ImageRouter: APITargetType {
    var baseURL: URL {
        switch self {
        case .putImage(let presignedURL, _):
            return URL(string: "\(presignedURL)")!
        default:
            return URL(string: "\(Config.baseUrl)")!
        }
    }
    
    var path: String {
        switch self {
        case .generatePresignedURL:
            return "/presigned-url"
        case .putImage:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .putImage:
            return .put
        default:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .generatePresignedURL(let request):
            return .requestJSONEncodable(request)
        case .putImage(_, let data):
            return .requestData(data)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .putImage:
            return ["Content-Type": "image/jpeg"]
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
