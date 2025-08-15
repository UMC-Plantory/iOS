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
}

    extension ChatRouter: APITargetType {
        var baseURL: URL {
            return URL(string: "\(Config.baseUrl)")!
        }
        
    var path: String {
        switch self {
        case .postChat, .getChatsList:
            return "/chats"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postChat:
            return .post
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
                return .requestParameters(parameters: ["cursor": cursor], encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        let json: String
        switch self {
        case .postChat:
            json = """
            {
                "isSuccess": true,
                "code": "COMMON200",
                "message": "성공입니다.",
                "result": {
                    "content": "요즘 감정의 기복이 심했던 것 같아요. 우울할 때는 혼자 감당하려 하지 말고, 주변 사람에게 살짝 기대보세요. 당신의 마음도 소중하니까요. 작은 산책이나 좋아하는 음악 듣기도 도움이 될 거예요. 힘든 마음, 천천히 다독이며 잘 돌봐주세요. 언제나 응원할게요.",
                    "createdAt": "2025-08-12T20:25",
                    "isMember": false
                }
            }
            """
        case .getChatsList:
            json = """
            {
                "isSuccess": true,
                "code": "COMMON200",
                "message": "성공입니다.",
                "result": [
                    {
                    "content": "우울할 때는 우선적으로 자신을 이해하고 위로해주는 것이 중요해요. 자기관리를 잘하고, 자신에게 대해 긍정적으로 생각하는 것도 좋은 방법이에요. 그리고 주변 사람들과 소통하며 좋은 에너지를 얻는 것도 도움이 될 거예요. 어떤 활동을 통해 마음을 치유하고 기분을 전환해보는 것도 좋은 방법이에요. 함께 하고 싶은 활동이 있나요? 함께 고민을 나누며 해결책을 찾아보는 것도 좋은 방법이에요. 함께해요! 😊",
                    "createAt": "2025-07-17T17:21",
                    "isMember": false
                    },
                    {
                    "content": "우울할 때 기분이 어떻게 하면 좋아질까",
                    "createAt": "2025-07-17T17:21",
                    "isMember": true
                    },
                    {
                    "content": "비가 오면 기분이 조금 우울해지는 것 같죠. 마음이 편하지 않으시겠어요. 함께 이야기를 나누며 마음을 털어놓아보세요. 제가 당신을 듣고 싶어요. 함께 이 감정을 헤쳐나가는 데 도움이 될 거예요. 😊",
                    "createAt": "2025-07-17T17:20",
                    "isMember": false
                    },
                    {
                    "content": "오늘 비가 와서 좀 처지는 것 같아",
                    "createAt": "2025-07-17T17:20",
                    "isMember": true
                    },
                    {
                    "content": "안녕하세요. 어떤 일이 있으신가요? 힘든 일이 있거나 고민거리가 있다면 말해주세요. 함께 이야기 나누며 해결해보도록 할게요. 😊",
                    "createAt": "2025-07-17T17:20",
                    "isMember": false
                    },
                    {
                    "content": "안녕",
                    "createAt": "2025-07-17T17:20",
                    "isMember": true
                    },
                    {
                    "content": "우울할 때는 우선적으로 자신을 이해하고 위로해주는 것이 중요해요. 자기관리를 잘하고, 자신에게 대해 긍정적으로 생각하는 것도 좋은 방법이에요. 그리고 주변 사람들과 소통하며 좋은 에너지를 얻는 것도 도움이 될 거예요. 어떤 활동을 통해 마음을 치유하고 기분을 전환해보는 것도 좋은 방법이에요. 함께 하고 싶은 활동이 있나요? 함께 고민을 나누며 해결책을 찾아보는 것도 좋은 방법이에요. 함께해요! 😊",
                    "createAt": "2025-07-17T17:21",
                    "isMember": false
                    },
                    {
                    "content": "우울할 때 기분이 어떻게 하면 좋아질까",
                    "createAt": "2025-07-17T17:21",
                    "isMember": true
                    },
                    {
                    "content": "비가 오면 기분이 조금 우울해지는 것 같죠. 마음이 편하지 않으시겠어요. 함께 이야기를 나누며 마음을 털어놓아보세요. 제가 당신을 듣고 싶어요. 함께 이 감정을 헤쳐나가는 데 도움이 될 거예요. 😊",
                    "createAt": "2025-07-17T17:20",
                    "isMember": false
                    },
                    {
                    "content": "오늘 비가 와서 좀 처지는 것 같아",
                    "createAt": "2025-07-17T17:20",
                    "isMember": true
                    },
                    {
                    "content": "안녕하세요. 어떤 일이 있으신가요? 힘든 일이 있거나 고민거리가 있다면 말해주세요. 함께 이야기 나누며 해결해보도록 할게요. 😊",
                    "createAt": "2025-07-17T17:20",
                    "isMember": false
                    },
                    {
                    "content": "안녕",
                    "createAt": "2025-07-17T17:20",
                    "isMember": true
                    },
                    {
                    "content": "우울할 때는 우선적으로 자신을 이해하고 위로해주는 것이 중요해요. 자기관리를 잘하고, 자신에게 대해 긍정적으로 생각하는 것도 좋은 방법이에요. 그리고 주변 사람들과 소통하며 좋은 에너지를 얻는 것도 도움이 될 거예요. 어떤 활동을 통해 마음을 치유하고 기분을 전환해보는 것도 좋은 방법이에요. 함께 하고 싶은 활동이 있나요? 함께 고민을 나누며 해결책을 찾아보는 것도 좋은 방법이에요. 함께해요! 😊",
                    "createAt": "2025-07-17T17:21",
                    "isMember": false
                    },
                    {
                    "content": "우울할 때 기분이 어떻게 하면 좋아질까",
                    "createAt": "2025-07-17T17:21",
                    "isMember": true
                    },
                    {
                    "content": "비가 오면 기분이 조금 우울해지는 것 같죠. 마음이 편하지 않으시겠어요. 함께 이야기를 나누며 마음을 털어놓아보세요. 제가 당신을 듣고 싶어요. 함께 이 감정을 헤쳐나가는 데 도움이 될 거예요. 😊",
                    "createAt": "2025-07-17T17:20",
                    "isMember": false
                    },
                    {
                    "content": "오늘 비가 와서 좀 처지는 것 같아",
                    "createAt": "2025-07-17T17:20",
                    "isMember": true
                    },
                    {
                    "content": "안녕하세요. 어떤 일이 있으신가요? 힘든 일이 있거나 고민거리가 있다면 말해주세요. 함께 이야기 나누며 해결해보도록 할게요. 😊",
                    "createAt": "2025-07-17T17:20",
                    "isMember": false
                    },
                    {
                    "content": "안녕",
                    "createAt": "2025-07-17T17:20",
                    "isMember": true
                    }
                ]
            }
            """
        }
        return Data(json.utf8)
    }
}
