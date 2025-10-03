//
//  ChatView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct ChatView: View {
    
    // MARK: - Property
    
    @EnvironmentObject var popupManager: PopupManager
    
    @StateObject var viewModel: ChatViewModel
    
//    @State var isSearching: Bool = false
    
    @FocusState private var isFocused: Bool
    
    // MARK: - Init

    /// DIContainer을 주입받아 초기화
    init(
        container: DIContainer
    ) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(container: container))
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            headerView
            
            chatMessageView
            
            inputField
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
        .task {
            UIApplication.shared.hideKeyboard()
            await viewModel.getChatsList()
        }
        .toastView(toast: $viewModel.toast)
        .loadingIndicator(viewModel.isFetchingChats)
    }
    
    // MARK: - Chat Header
    @ViewBuilder
    private var headerView: some View {
        ZStack(alignment: .center) {
            Text("Plantory AI")
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.black)
            
            HStack(spacing: 20) {
                Spacer()
                
//                    Button(action: {
//                        withAnimation {
//                            isSearching = true
//                        }
//                    }, label: {
//                        Image("search")
//                            .resizable()
//                            .frame(width: 24, height: 24)
//                    })
                
                Button(action: {
                    popupManager.show {
                        PopUp(
                            title: "대화 내용을 초기화하시겠습니까?",
                            message: "대화 내용은 한 번 삭제하면 복구할 수 없습니다.",
                            confirmTitle: "삭제하기",
                            cancelTitle: "취소",
                            onConfirm: {
                                
                            },
                            onCancel: {
                                popupManager.dismiss()
                            }
                        )
                    }
                }, label: {
                    Image("reset")
                })
            }
        }
        .frame(height: 40)
    }
    
//    private var searchField: some View {
//        HStack {
//            HStack {
//                Image("search")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                
//                Spacer()
//                
//                TextField("대화내용 검색", text: $viewModel.query)
//                    .padding(.vertical, 10)
//                    .font(.pretendardRegular(16))
//                    .foregroundColor(.gray10)
//                    .submitLabel(.search)
//                    .onSubmit {
//                        
//                    }
//            }
//            .padding(.horizontal, 14)
//            .background(Color("gray03"))
//            .cornerRadius(8)
//        
//            Button(action: {
//                withAnimation {
//                    isSearching = false
//                }
//            }, label: {
//                Text("취소")
//                    .font(.pretendardRegular(18))
//                    .foregroundStyle(.black)
//            })
//            .padding(.leading, 12)
//        }
//    }
    
    // MARK: - Chat Message List
    @ViewBuilder
    private var chatMessageView: some View {
        if viewModel.messages.isEmpty {
            NothingView(
                mainText: "아직 기록된 대화가 없어요",
                subText: "첫 대화를 시작해 보세요!"
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            ScrollViewReader { proxy in
                RefreshableView(
                    reverse: true,
                    isLastPage: !viewModel.hasNext
                ) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages, id: \.id) { chat in
                            //MARK: - Chat Message View
                            ChatBox(chatModel: chat)
//                                .id(chat.id)
                        }
                        
                        if viewModel.isPostingChat {
                            ChatLoadingBox()
                            
                        }
                    }
                } onRefresh: {
                    await viewModel.getChatsList()
                }
                .task(id: viewModel.messages.count) {
                    if viewModel.shouldScrollToBottom {
                        scrollToLastMessage(proxy: proxy)
                        viewModel.shouldScrollToBottom = false
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    // MARK: - Input Field
    
    private var inputField: some View {
        HStack {
            TextField("플랜토리에게 하고 싶은 말을 입력해보세요.", text: $viewModel.textInput)
                .font(.pretendardRegular(12))
                .foregroundStyle(.black)
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit({
                    guard !viewModel.isPostingChat else { return }
                    Task {
                        await viewModel.sendMessage()
                    }
                    isFocused = true
                })
            
            //MARK: - Send Button
            SendButton(
                isDisabled: viewModel.textInput.isEmpty,
                action: {
                    Task {
                        await viewModel.sendMessage()
                    }
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
