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
        let newMessage = ChatMessage(
            role: .user,
            content: textInput,
            createAt: Date().hourMinuteString
        )
        messages.append(newMessage)
        shouldScrollToBottom = true
        self.postChat()
    }
    
    
    // MARK: - API
    
    /// 채팅 요청
    public func postChat() {
        isLoading = true

        let request = ChatRequest(content: textInput)

        container.useCaseService.chatService.postChat(chatData: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // 오류 발생 시 처리
                if case .failure(let failure) = completion {
                    print("채팅 요청 오류: \(failure)")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                let newChat = ChatMessage(
                    role: .model,
                    content: response,
                    createAt: Date().hourMinuteString
                )
                self?.messages.append(newChat)
                self?.isLoading = false
                self?.textInput = ""
            })
            .store(in: &cancellables)
    }
    
    /// 최초 진입 시, 이전 대화 기록 조회
    public func getLatestChat() {
        isLoading = true

        container.useCaseService.chatService.getLatestChat()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // 오류 발생 시 처리
                if case .failure(let failure) = completion {
                    print("채팅 불러오기 오류: \(failure)")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                self?.messages = response
                    .map { ChatMessage(from: $0) }
                    .reversed()
                    .map { $0 }
                self?.shouldScrollToBottom = true
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    /// 이전 대화 기록 조회에서, 커서 페이징
    public func getLatestChat(before: String) {
        guard !isLoading, !isLast else { return }
        isLoading = true

        let request = BeforeChatRequest(before: before)
        
        container.useCaseService.chatService.getBeforeChat(beforeData: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // 오류 발생 시 처리
                if case .failure(let failure) = completion {
                    print("채팅 불러오기 오류: \(failure)")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                if response.isEmpty {
                    self?.isLast = true
                    self?.isLoading = false
                    return
                } else {
                    let mappedMessages = response
                        .map { ChatMessage(from: $0) }
                    self?.messages.insert(contentsOf: mappedMessages, at: 0)
                    self?.isLoading = false
                }
            })
            .store(in: &cancellables)
    }
}

// FIX-ME: 백엔드에 createAt 보내줄 수 있는지 이야기하기
extension Date {
    var hourMinuteString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}
