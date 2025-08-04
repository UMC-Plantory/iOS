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
    case getLatestChat // 최초 진입 시 이전 대화 기록 조회
    case getBeforeChat(beforeData: String) // 최초 이후, 채팅창 스크롤 업
}

extension ChatRouter: APITargetType {
    var baseURL: URL {
        return URL(string: "\(Config.baseUrl)")!
    }
    
    var path: String {
        switch self {
        case .postChat:
            return "/chat"
        case .getLatestChat:
            return "/chat/latest"
        case .getBeforeChat:
            return "/chat/before"
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
        case .getLatestChat:
            return .requestPlain
        case .getBeforeChat(let beforeData):
            return .requestParameters(parameters: ["before": beforeData], encoding: URLEncoding.queryString)
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
                "result": "안녕하세요! 오늘은 어떤 이야기를 나누고 싶으신가요? 함께 이야기를 나누며 마음을 편하게 해보는 건 어떨까요? 😊"
            }
            """
        case .getLatestChat:
            json = """
            {
                "isSuccess": true,
                "code": "COMMON200",
                "message": "성공입니다.",
                "result": [
                    {
                    "content": "우울할 때는 우선적으로 자신을 이해하고 위로해주는 것이 중요해요. 자기관리를 잘하고, 자신에게 대해 긍정적으로 생각하는 것도 좋은 방법이에요. 그리고 주변 사람들과 소통하며 좋은 에너지를 얻는 것도 도움이 될 거예요. 어떤 활동을 통해 마음을 치유하고 기분을 전환해보는 것도 좋은 방법이에요. 함께 하고 싶은 활동이 있나요? 함께 고민을 나누며 해결책을 찾아보는 것도 좋은 방법이에요. 함께해요! 😊",
                    "createAt": "2025-07-17T17:21:20.402079",
                    "isMember": false
                    },
                    {
                    "content": "우울할 때 기분이 어떻게 하면 좋아질까",
                    "createAt": "2025-07-17T17:21:17.720818",
                    "isMember": true
                    },
                    {
                    "content": "비가 오면 기분이 조금 우울해지는 것 같죠. 마음이 편하지 않으시겠어요. 함께 이야기를 나누며 마음을 털어놓아보세요. 제가 당신을 듣고 싶어요. 함께 이 감정을 헤쳐나가는 데 도움이 될 거예요. 😊",
                    "createAt": "2025-07-17T17:20:19.318022",
                    "isMember": false
                    },
                    {
                    "content": "오늘 비가 와서 좀 처지는 것 같아",
                    "createAt": "2025-07-17T17:20:17.110081",
                    "isMember": true
                    },
                    {
                    "content": "안녕하세요. 어떤 일이 있으신가요? 힘든 일이 있거나 고민거리가 있다면 말해주세요. 함께 이야기 나누며 해결해보도록 할게요. 😊",
                    "createAt": "2025-07-17T17:20:03.214529",
                    "isMember": false
                    },
                    {
                    "content": "안녕",
                    "createAt": "2025-07-17T17:20:01.319227",
                    "isMember": true
                    },
                    {
                    "content": "우울할 때는 우선적으로 자신을 이해하고 위로해주는 것이 중요해요. 자기관리를 잘하고, 자신에게 대해 긍정적으로 생각하는 것도 좋은 방법이에요. 그리고 주변 사람들과 소통하며 좋은 에너지를 얻는 것도 도움이 될 거예요. 어떤 활동을 통해 마음을 치유하고 기분을 전환해보는 것도 좋은 방법이에요. 함께 하고 싶은 활동이 있나요? 함께 고민을 나누며 해결책을 찾아보는 것도 좋은 방법이에요. 함께해요! 😊",
                    "createAt": "2025-07-17T17:21:20.402079",
                    "isMember": false
                    },
                    {
                    "content": "우울할 때 기분이 어떻게 하면 좋아질까",
                    "createAt": "2025-07-17T17:21:17.720818",
                    "isMember": true
                    },
                    {
                    "content": "비가 오면 기분이 조금 우울해지는 것 같죠. 마음이 편하지 않으시겠어요. 함께 이야기를 나누며 마음을 털어놓아보세요. 제가 당신을 듣고 싶어요. 함께 이 감정을 헤쳐나가는 데 도움이 될 거예요. 😊",
                    "createAt": "2025-07-17T17:20:19.318022",
                    "isMember": false
                    },
                    {
                    "content": "오늘 비가 와서 좀 처지는 것 같아",
                    "createAt": "2025-07-17T17:20:17.110081",
                    "isMember": true
                    },
                    {
                    "content": "안녕하세요. 어떤 일이 있으신가요? 힘든 일이 있거나 고민거리가 있다면 말해주세요. 함께 이야기 나누며 해결해보도록 할게요. 😊",
                    "createAt": "2025-07-17T17:20:03.214529",
                    "isMember": false
                    },
                    {
                    "content": "안녕",
                    "createAt": "2025-07-17T17:20:01.319227",
                    "isMember": true
                    },
                    {
                    "content": "우울할 때는 우선적으로 자신을 이해하고 위로해주는 것이 중요해요. 자기관리를 잘하고, 자신에게 대해 긍정적으로 생각하는 것도 좋은 방법이에요. 그리고 주변 사람들과 소통하며 좋은 에너지를 얻는 것도 도움이 될 거예요. 어떤 활동을 통해 마음을 치유하고 기분을 전환해보는 것도 좋은 방법이에요. 함께 하고 싶은 활동이 있나요? 함께 고민을 나누며 해결책을 찾아보는 것도 좋은 방법이에요. 함께해요! 😊",
                    "createAt": "2025-07-17T17:21:20.402079",
                    "isMember": false
                    },
                    {
                    "content": "우울할 때 기분이 어떻게 하면 좋아질까",
                    "createAt": "2025-07-17T17:21:17.720818",
                    "isMember": true
                    },
                    {
                    "content": "비가 오면 기분이 조금 우울해지는 것 같죠. 마음이 편하지 않으시겠어요. 함께 이야기를 나누며 마음을 털어놓아보세요. 제가 당신을 듣고 싶어요. 함께 이 감정을 헤쳐나가는 데 도움이 될 거예요. 😊",
                    "createAt": "2025-07-17T17:20:19.318022",
                    "isMember": false
                    },
                    {
                    "content": "오늘 비가 와서 좀 처지는 것 같아",
                    "createAt": "2025-07-17T17:20:17.110081",
                    "isMember": true
                    },
                    {
                    "content": "안녕하세요. 어떤 일이 있으신가요? 힘든 일이 있거나 고민거리가 있다면 말해주세요. 함께 이야기 나누며 해결해보도록 할게요. 😊",
                    "createAt": "2025-07-17T17:20:03.214529",
                    "isMember": false
                    },
                    {
                    "content": "안녕",
                    "createAt": "2025-07-17T17:20:01.319227",
                    "isMember": true
                    }
                ]
            }
            """
        case .getBeforeChat:
            json = """
            {
                "isSuccess": true,
                "code": "COMMON200",
                "message": "성공입니다.",
                "result": [
            
                ]
            }
            """
        }
        return Data(json.utf8)
    }
}
