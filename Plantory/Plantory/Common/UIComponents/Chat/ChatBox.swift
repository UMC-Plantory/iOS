//
//  ChatBox.swift
//  Plantory
//
//  Created by 주민영 on 7/8/25.
//

import SwiftUI

struct ChatBox: View {
    let chatModel: ChatMessage
    
    var body: some View {
        if chatModel.role == .model {
            modelMessage
        } else {
            userMessage
        }
    }
    
    private var userMessage: some View {
        HStack(alignment: .bottom, spacing: 6) {
            Text(extractTime(from: chatModel.time) ?? "시간없음")
                .font(.pretendardRegular(10))
                .foregroundStyle(.black01)
            
            HStack(alignment: .top) {
                Group {
                    if chatModel.message.isEmpty {
                        ProgressView()
                            .padding()
                            .tint(.gray11)
                        
                    } else {
                        Text(chatModel.message)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .font(.pretendardRegular(14))
                            .foregroundColor(.gray11)
                    }
                }
                .background(.green02)
                .clipShape(UserChatBubbleShape())
            }
        }
        .frame(maxWidth: .infinity, alignment: .topTrailing)
    }
    
    private var modelMessage: some View {
        HStack(alignment: .bottom, spacing: 6) {
            HStack(alignment: .top) {
                Image("chat_logo")
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Group {
                    if chatModel.message.isEmpty {
                        ProgressView()
                            .padding()
                            .tint(.gray11)
                        
                    } else {
                        Text(chatModel.message)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .font(.pretendardRegular(14))
                            .foregroundColor(.gray11)
                    }
                }
                .background(.white01)
                .clipShape(ModelChatBubbleShape())
                .overlay(
                    ModelChatBubbleShape()
                        .stroke(.black01, lineWidth: 1)
                )
            }
            
            Text(extractTime(from: chatModel.time) ?? "시간없음")
                .font(.pretendardRegular(10))
                .foregroundStyle(.black01)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    // datetime 문자열을 공백 기준으로 나눠서 시간만 반환
    func extractTime(from datetime: String) -> String? {
        let components = datetime.components(separatedBy: " ")
        return components.count == 2 ? components.last : nil
    }
}

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
