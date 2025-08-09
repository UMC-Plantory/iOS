//
//  ChatViewModel.swift
//  Plantory
//
//  Created by 주민영 on 7/9/25.
//

import SwiftUI
import Combine
import Moya

@Observable
class ChatViewModel {
    
    // MARK: - 메시지
    
    /// 화면에 띄울 메시지 목록
    var messages: [ChatMessage] = []
    
    /// 페이지네이션을 위해, 마지막 메시지 저장
    var lastMessage: ChatMessage? = nil
    
    /// 로딩 중임을 나타냄
    var isLoading: Bool = false
    
    /// 메시지 페이지네이션에서 마지막인지를 나타냄
    var isLast: Bool = false
    
    // 스크롤 트리거
    var shouldScrollToBottom = false
    
    // MARK: - 의존성 주입 및 비동기 처리
    
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - 사용자 입력
    
    /// 입력된 채팅 본문
    var textInput = ""
    
    // MARK: - 초기화
        
    init(container: DIContainer) {
        self.container = container
    }
    
    // MARK: - 함수
    public func sendMessage() {
        let text = textInput
        self.textInput = ""
        
        let newMessage = ChatMessage(
            role: .user,
            content: text,
            createAt: Date().hourMinuteString
        )
        messages.append(newMessage)
        
        self.postChat(text: text)
    }
    
    
    // MARK: - API
    
    /// 채팅 요청
    public func postChat(text: String) {
        guard !isLoading else { return }
        isLoading = true

        let request = ChatRequest(content: text)

        container.useCaseService.chatService.postChat(chatData: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // 오류 발생 시 처리
                if case .failure(let failure) = completion {
                    print("채팅 요청 오류: \(failure)")
                    self?.isLoading = false
                    // FIX-ME: 에러 토스트 추가하기
                    self?.messages.removeLast()
                }
            }, receiveValue: { [weak self] response in
                let newChat = ChatMessage(
                    role: .model,
                    content: response,
                    createAt: Date().hourMinuteString
                )
                self?.messages.append(newChat)
                self?.isLoading = false
                self?.shouldScrollToBottom = true
            })
            .store(in: &cancellables)
    }
    
    /// 최초 진입 시, 이전 대화 기록 조회
    public func getLatestChat() {
        guard !isLoading else { return }
        
        container.useCaseService.chatService.getLatestChat()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // 오류 발생 시 처리
                if case .failure(let failure) = completion {
                    print("채팅 불러오기 오류: \(failure)")
                }
            }, receiveValue: { [weak self] response in
                let convertedResponse = response
                    .map { ChatMessage(from: $0) }
                
                self?.messages = convertedResponse
                    .reversed()
                    .map { $0 }
                
                self?.shouldScrollToBottom = true
                self?.isLast = false
                
                /// 페이지네이션을 위해 마지막 메시지를 저장
                if let last = convertedResponse.last {
                    self?.lastMessage = last
                }
            })
            .store(in: &cancellables)
    }
    
    /// 이전 대화 기록 조회에서, 커서 페이징
    public func getBeforeChat() {
        guard let lastCreateAt = lastMessage?.createAt, !isLoading, !isLast else { return }
        
        container.useCaseService.chatService.getBeforeChat(beforeData: lastCreateAt)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // 오류 발생 시 처리
                if case .failure(let failure) = completion {
                    print("채팅 불러오기 오류: \(failure)")
                }
            }, receiveValue: { [weak self] response in
                if response.isEmpty {
                    self?.isLast = true
                    return
                } else {
                    let convertedResponse = response
                        .map { ChatMessage(from: $0) }
                    
                    let reversedResponse = convertedResponse
                        .reversed()
                        .map { $0 }
                    self?.messages.insert(contentsOf: reversedResponse, at: 0)
                    
                    /// 페이지네이션을 위해 마지막 메시지를 저장
                    if let last = convertedResponse.last {
                        self?.lastMessage = last
                    }
                }
            })
            .store(in: &cancellables)
    }
}

// FIX-ME: 백엔드에 createAt 보내줄 수 있는지 이야기하기
extension Date {
    var hourMinuteString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}
