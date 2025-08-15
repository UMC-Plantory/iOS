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
    
    /// 페이지네이션을 위해, 마지막 메시지의 createdAt 저장
    var lastCreateAt: String? = nil
    
    /// postChat 함수가 로딩 중임을 나타냄
    var isPostingChat: Bool = false
    
    /// getLatestChat 함수가 로딩 중임을 나타냄
    var isFetchingChats: Bool = false
    
    /// 메시지 페이지네이션에서 마지막인지를 나타냄
    var isLast: Bool = false
    
    // 스크롤 트리거
    var shouldScrollToBottom = false
    
    // MARK: - Toast
    
    var toast: CustomToast? = nil
    
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
            createdAt: Date().isoYearMonthDayHourMinuteString
        )
        messages.append(newMessage)
        
        self.postChat(text: text)
    }
    
    
    // MARK: - API
    
    /// 채팅 요청
    public func postChat(text: String) {
        guard !isPostingChat, !isFetchingChats else { return }
        isPostingChat = true

        let request = ChatRequest(content: text)

        container.useCaseService.chatService.postChat(chatData: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // 오류 발생 시 처리
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "채팅 요청 오류",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("채팅 요청 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                    
                    self?.messages.removeLast()
                    self?.isPostingChat = false
                }
            }, receiveValue: { [weak self] response in
                let newChat = ChatMessage(
                    role: .model,
                    content: response.content,
                    createdAt: response.createdAt
                )
                self?.messages.append(newChat)
                self?.isPostingChat = false
                self?.shouldScrollToBottom = true
            })
            .store(in: &cancellables)
    }
    
    /// 이전 대화 기록 조회에서, 커서 페이징
    public func getChatsList() {
        guard !isPostingChat, !isFetchingChats, !isLast else { return }
        
        container.useCaseService.chatService.getChatsList(cursor: lastCreateAt)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // 오류 발생 시 처리
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "채팅 요청 오류",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("채팅 불러오기 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                    self?.isFetchingChats = false
                }
            }, receiveValue: { [weak self] response in
                if response.isEmpty {
                    self?.isLast = true
                } else {
                    let convertedResponse = response
                        .map { ChatMessage(from: $0) }
                    
                    let reversedResponse = convertedResponse
                        .reversed()
                        .map { $0 }
                    self?.messages.insert(contentsOf: reversedResponse, at: 0)
                    
                    /// 페이지네이션을 위해 마지막 메시지를 저장
                    if let last = convertedResponse.last {
                        self?.lastCreateAt = last.createdAt
                    }
                }
                self?.isFetchingChats = false
            })
            .store(in: &cancellables)
    }
}

// MARK: - 보내는 메시지를 띄우기 위한 날짜 변환 함수

extension Date {
    var isoYearMonthDayHourMinuteString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: self)
    }
}
