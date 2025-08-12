//
//  ImageService.swift
//  Plantory
//
//  Created by 주민영 on 8/12/25.
//

import Foundation
import CombineMoya
import Moya
import Combine

/// 이미지 서비스 프로토콜
protocol ImageServiceProtocol {
    
    /// presigned URL 발급
    func generatePresignedURL(request: PresignedRequest) -> AnyPublisher<PresignedResponse, APIError>
    
    /// 이미지 업로드
    func putImage(presignedURL: String, data: Data) -> AnyPublisher<Void, APIError>
}

/// Image API를 사용하는 서비스
final class ImageService: ImageServiceProtocol {
    
    /// MoyaProvider를 통해 API 요청을 전송
    let provider: MoyaProvider<ImageRouter>
    let noTokenProvider: MoyaProvider<ImageRouter>
    
    // MARK: - Initializer
    
    /// 기본 initializer - verbose 로그 플러그인을 포함한 provider 생성
    init(provider: MoyaProvider<ImageRouter> = APIManager.shared.createProvider(for: ImageRouter.self), noTokenProvider: MoyaProvider<ImageRouter> = APIManager.shared.createNoAuthProvider(for: ImageRouter.self)) {
        self.provider = provider
        self.noTokenProvider = noTokenProvider
    }
    
    // MARK: - presigned URL 발급
    
    /// presigned URL 발급
    /// - Parameter request: presigned URL 발급 요청 모델
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func generatePresignedURL(request: PresignedRequest) -> AnyPublisher<PresignedResponse, APIError> {
        return provider.requestResult(.generatePresignedURL(request: request), type: PresignedResponse.self)
    }
    
    // MARK: - 이미지 업로드
    
    /// 이미지 업로드
    /// - Parameter presignedURL: 요청을 보낼 URL
    /// - Parameter data: 업로드할 이미지 파일을 변환한 데이터
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func putImage(presignedURL: String, data: Data) -> AnyPublisher<Void, APIError> {
        return noTokenProvider
                .requestPublisher(.putImage(presignedURL: presignedURL, data: data))
                .tryMap { res in
                    guard (200...299).contains(res.statusCode) else {
                        let body = String(data: res.data, encoding: .utf8) ?? "<no body>"
                        throw APIError.serverError(code: "\(res.statusCode)", message: body)
                    }
                    // 바디 인코딩 없이 성공만 표시
                    return ()
                }
                .mapError { err in
                    if let moya = err as? MoyaError { return .moyaError(moya) }
                    if let api  = err as? APIError  { return api }
                    return .unknown
                }
                .eraseToAnyPublisher()

    }
}
