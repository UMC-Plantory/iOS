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
                    .background(.white)
                    .clipShape(ModelChatBubbleShape())
                    .overlay(
                        ModelChatBubbleShape()
                            .stroke(.black01Dynamic, lineWidth: 1)
                    )
            }
            
            createAtView
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    /// 채팅에서 시간을 나타내는 뷰
    private var createAtView: some View {
        Text(extractTime(from: chatModel.createdAt) ?? "시간 없음")
            .font(.pretendardRegular(10))
            .foregroundStyle(.black01Dynamic)
    }
    
    /// 채팅에서 메시지를 나타내는 뷰
    private var messageView: some View {
        Text(chatModel.content.customLineBreak())
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .font(.pretendardRegular(14))
            .foregroundColor(.black)
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
                    .background(.white01Dynamic)
                    .clipShape(ModelChatBubbleShape())
                    .overlay(
                        ModelChatBubbleShape()
                            .stroke(.black01Dynamic, lineWidth: 1)
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
func extractTime(from dateString: String) -> String? {
    let formats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ", // 초+밀리초 있음
        "yyyy-MM-dd'T'HH:mm"          // 초 없음
    ]
    
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    for format in formats {
        formatter.dateFormat = format
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
    return nil
}
