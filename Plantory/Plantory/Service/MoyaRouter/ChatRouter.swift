//
//  ChatRouter.swift
//  Plantory
//
//  Created by 주민영 on 7/25/25.
//

import Foundation
import Moya

enum ChatRouter {
    case postChat(chatData: ChatRequest) // 채팅 보내기
    case getChatsList(cursor: String?) // 채팅 기록 조회
    case deleteChats // 채팅 기록 초기화
}

    extension ChatRouter: APITargetType {
        var baseURL: URL {
            return URL(string: "\(Config.baseUrl)")!
        }
        
    var path: String {
        switch self {
        case .postChat, .getChatsList, .deleteChats:
            return "/chats"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postChat:
            return .post
        case .deleteChats:
            return .delete
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .postChat(let chatData):
            return .requestJSONEncodable(chatData)
        case .getChatsList(let cursor):
            if let cursor = cursor {
                return .requestParameters(parameters: ["cursor": cursor, "size": 8], encoding: URLEncoding.queryString)
            } else {
                return .requestParameters(parameters: ["size": 8], encoding: URLEncoding.queryString)
            }
        case .deleteChats:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
