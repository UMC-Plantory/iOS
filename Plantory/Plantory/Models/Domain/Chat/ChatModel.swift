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
    var createdAt: String
    
    init(role: ChatRole, content: String, createdAt: String) {
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
    
    init(from response: ChatResponse) {
        self.role = response.isMember ? .user : .model
        self.content = response.content
        self.createdAt = response.createdAt
    }
}
