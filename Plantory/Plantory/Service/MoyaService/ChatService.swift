//
//  ChatService.swift
//  Plantory
//
//  Created by 주민영 on 7/31/25.
//
import Foundation
import CombineMoya
import Moya
import Combine

/// 채팅 서비스 프로토콜
protocol ChatServiceProtocol {
    
    /// 채팅 요청
    func postChat(chatData: ChatRequest) -> AnyPublisher<ChatResponse, APIError>
    
    /// 채팅 기록 조회
    func getChatsList(cursor: String?) -> AnyPublisher<ChatResult, APIError>
}

/// Chat API를 사용하는 서비스
final class ChatService: ChatServiceProtocol {
    
    /// MoyaProvider를 통해 API 요청을 전송
    let provider: MoyaProvider<ChatRouter>
    
    // MARK: - Initializer
    
    /// 기본 initializer - verbose 로그 플러그인을 포함한 provider 생성
    init(provider: MoyaProvider<ChatRouter> = APIManager.shared.createProvider(for: ChatRouter.self)) {
        self.provider = provider
    }
    
    // MARK: - 채팅 요청
    
    /// 채팅 요청
    /// - Parameter request: 채팅 요청 모델
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func postChat(chatData: ChatRequest) -> AnyPublisher<ChatResponse, APIError> {
        return provider.requestResult(.postChat(chatData: chatData), type: ChatResponse.self)
    }

    // MARK: - 채팅 기록 조회
    
    /// 채팅 요청
    /// - Parameter cursor: 커서값 (마지막으로 조회한 chat의 createdAt)
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func getChatsList(cursor: String?) -> AnyPublisher<ChatResult, APIError> {
        return provider.requestResult(.getChatsList(cursor: cursor), type: ChatResult.self)
    }
}
