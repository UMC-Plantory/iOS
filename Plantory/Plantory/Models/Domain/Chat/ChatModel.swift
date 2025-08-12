//
//  ChatModel.swift
//  Plantory
//
//  Created by 주민영 on 7/8/25.
//

import Foundation

enum ChatRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var role: ChatRole
    var content: String
    var createAt: String
    
    init(role: ChatRole, content: String, createAt: String) {
        self.role = role
        self.content = content
        self.createAt = createAt
    }
    
    init(from response: ChatResponse) {
        self.role = response.isMember ? .user : .model
        self.content = response.content
        self.createAt = extractHourAndMinute(from: response.createAt) ?? "시간 없음"
    }
}

/// datetime 문자열을 시간만 반환
func extractHourAndMinute(from datetime: String) -> String? {
    let parts = datetime.components(separatedBy: "T")
    guard parts.count == 2 else { return nil }

    let timeString = parts[1]  // "17:21:17.720818"
    let timeComponents = timeString.components(separatedBy: ":")
    guard timeComponents.count >= 2 else { return nil }

    return "\(timeComponents[0]):\(timeComponents[1])"
}
