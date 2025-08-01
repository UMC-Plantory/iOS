//
//  ChatDTO.swift
//  Plantory
//
//  Created by 주민영 on 7/31/25.
//

import Foundation

struct ChatRequest: Codable {
    let content: String
}

struct BeforeChatRequest: Codable {
    let before: String
}

struct ChatResponse: Codable {
    let content: String
    let createAt: String
    let isMember: Bool
}
