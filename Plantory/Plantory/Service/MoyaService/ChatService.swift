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
    
    /// 최초 진입 시, 이전 대화 기록 조회
    func getLatestChat() -> AnyPublisher<[ChatResponse], APIError>
    
    /// 이전 대화 기록 조회에서, 커서 페이징
    func getBeforeChat(beforeData: String) -> AnyPublisher<[ChatResponse], APIError>
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

    // MARK: - 최초 진입 시, 이전 대화 기록 조회
    
    /// 채팅 요청
    /// - Parameter request: 채팅 요청 모델
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func getLatestChat() -> AnyPublisher<[ChatResponse], APIError> {
        return provider.requestResult(.getLatestChat, type: [ChatResponse].self)
    }

    // MARK: - 이전 대화 기록 조회에서, 커서 페이징
    /// 채팅 요청
    /// - Parameter request: 마지막 메세제의 시간을 요청
    /// - Returns: 채팅 응답을 Combine Publisher 형태로 반환
    func getBeforeChat(beforeData: String) -> AnyPublisher<[ChatResponse], APIError> {
        return provider.requestResult(.getBeforeChat(beforeData: beforeData), type: [ChatResponse].self)
    }
}
