//
//  ChatView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct ChatView: View {
    
    // MARK: - Property
    
    @State var viewModel: ChatViewModel
    
    @FocusState private var isFocused: Bool
    
    // MARK: - Init

    /// DIContainer을 주입받아 초기화
    init(
        container: DIContainer,
    ) {
        self.viewModel = .init(container: container)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // MARK: - Chat Message List
            RefreshableView(
                reverse: true,
                isLastPage: viewModel.isLast
            ) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages, id: \.id) { chat in
                        //MARK: - Chat Message View
                        chatMessageView(chat)
                    }
                    
                    if viewModel.isLoading {
                        ChatLoadingBox()
                    }
                }
            } onRefresh: {
                viewModel.getBeforeChat()
            }
            .task {
                viewModel.getLatestChat()
            }
//            .onChange(of: viewModel.shouldScrollToBottom) {
//                scrollToLastMessage(proxy: proxy)
//            }
            
            // MARK: - Input Field
            HStack {
                TextField("플랜토리에게 하고 싶은 말을 입력해보세요.", text: $viewModel.textInput)
                    .font(.pretendardRegular(12))
                    .foregroundStyle(.black)
                    .focused($isFocused)
                    .submitLabel(.send)
                    .onSubmit({
                        guard !viewModel.isLoading else { return }
                        viewModel.sendMessage()
                        isFocused = true
                    })
                
                //MARK: - Send Button
                SendButton(
                    isDisabled: viewModel.textInput.isEmpty,
                    action: {
                        viewModel.sendMessage()
                        isFocused = true
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11.5)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray05, lineWidth: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .foregroundStyle(.white)
        .background {
            //MARK: - Background
            ZStack {
                Color.white
            }
            .ignoresSafeArea()
            .onTapGesture {
                isFocused = false
            }
            
        }
    }
    
    // MARK: - Chat Message View
    @ViewBuilder private func chatMessageView(_ message: ChatMessage) -> some View {
        // MARK: - Chat Message Box
        ChatBox(
            chatModel: message
        )
    }
    
    // MARK: 스크롤 제일 아래 메세지로 향하게
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        guard let recentMessage = viewModel.messages.last else { return }
                            
        DispatchQueue.main.async {
            withAnimation {
                proxy.scrollTo(recentMessage.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatView(container: .init())
}
