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
    var message: String
    var time: String
}
