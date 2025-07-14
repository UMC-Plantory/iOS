//
//  ChatView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct ChatView: View {
    @State var viewModel: ChatViewModel = ChatViewModel()
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            
            //MARK: - Chat Message List
            ScrollViewReader(content: { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { chatMessage in
                            //MARK: - Chat Message View
                            chatMessageView(chatMessage)
                        }
                    }
                }
                .scrollIndicators(.never)
                .onAppear {
                    scrollToLastMessage(proxy: proxy)
                }
                .onChange(of: viewModel.messages) {
                    scrollToLastMessage(proxy: proxy)
                }
            })
            
            //MARK: - Input Field
            Group {
                if viewModel.loadingResponse {
                    //MARK: - Loading indicator
                    ProgressView()
                        .tint(.white)
                        .frame(width: 30)
                } else {
                    HStack {
                        TextField("플랜토리에게 하고 싶은 말을 입력해보세요.", text: $viewModel.textInput)
                            .font(.pretendardRegular(12))
                            .foregroundStyle(.black)
                            .focused($isFocused)
                            .disabled(viewModel.loadingResponse)
                        
                        //MARK: - Send Button
                        SendButton(
                            isDisabled: viewModel.textInput.isEmpty,
                            action: {
                                print("send")
                            }
                        )
                    }
                }
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
    
    //MARK: - Chat Message View
    @ViewBuilder private func chatMessageView(_ message: ChatMessage) -> some View {
        //MARK: - Chat Message Box
        ChatBox(chatModel: message)
    }
    
    //MARK: 스크롤 제일 아래 메세지로 향하게
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
    ChatView()
}
