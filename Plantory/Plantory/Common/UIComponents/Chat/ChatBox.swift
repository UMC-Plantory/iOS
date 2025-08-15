//
//  ChatBox.swift
//  Plantory
//
//  Created by 주민영 on 7/8/25.
//

import SwiftUI

// MARK: - 채팅 셀

struct ChatBox: View {
    
    // MARK: - Property
    
    let chatModel: ChatMessage
    
    // MARK: - Body
    
    var body: some View {
        if chatModel.role == .model {
            modelMessage
        } else {
            userMessage
        }
    }
    
    /// 유저가 요청한 메시지를 담는 뷰
    private var userMessage: some View {
        HStack(alignment: .bottom, spacing: 6) {
            createAtView
            
            HStack(alignment: .top) {
                messageView
                    .background(.green02)
                    .clipShape(UserChatBubbleShape())
            }
        }
        .frame(maxWidth: .infinity, alignment: .topTrailing)
    }
    
    /// AI가 답변한 메시지를 담는 뷰
    private var modelMessage: some View {
        HStack(alignment: .bottom, spacing: 6) {
            HStack(alignment: .top) {
                Image("chat_logo")
                    .resizable()
                    .frame(width: 32, height: 32)
                
                messageView
                    .background(.white01)
                    .clipShape(ModelChatBubbleShape())
                    .overlay(
                        ModelChatBubbleShape()
                            .stroke(.black01, lineWidth: 1)
                    )
            }
            
            createAtView
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    /// 채팅에서 시간을 나타내는 뷰
    private var createAtView: some View {
        Text(extractHourAndMinute(from: chatModel.createdAt) ?? "시간 없음")
            .font(.pretendardRegular(10))
            .foregroundStyle(.black01)
    }
    
    /// 채팅에서 메시지를 나타내는 뷰
    private var messageView: some View {
        Text(chatModel.content)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .font(.pretendardRegular(14))
            .foregroundColor(.gray11)
    }
}

// MARK: - 로딩 전용 셀

struct ChatLoadingBox: View {
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            HStack(alignment: .top) {
                Image("chat_logo")
                    .resizable()
                    .frame(width: 32, height: 32)

                ProgressView()
                    .padding()
                    .tint(.gray11)
                    .background(.white01)
                    .clipShape(ModelChatBubbleShape())
                    .overlay(
                        ModelChatBubbleShape()
                            .stroke(.black01, lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

// MARK: - Shape

struct UserChatBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 10, height: 10)
        )
        return Path(path.cgPath)
    }
}

struct ModelChatBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: 10, height: 10)
        )
        return Path(path.cgPath)
    }
}

// MARK: - 시간 변환 함수

/// datetime 문자열을 시간만 반환
func extractHourAndMinute(from datetime: String) -> String? {
    guard let tIndex = datetime.firstIndex(of: "T") else { return nil }
    let timePart = datetime[datetime.index(after: tIndex)...]
    return String(timePart)
}
