//
//  ChatViewModel.swift
//  Plantory
//
//  Created by 주민영 on 7/9/25.
//

import SwiftUI

@Observable
class ChatViewModel {
    var textInput = ""
    var loadingResponse = false
    
    // 아래는 더미데이터
    var messages: [ChatMessage] = [
        ChatMessage(role: .user, message: "오늘 하루 너무 힘들었어...", time: "2025-07-08 19:20"),
        ChatMessage(role: .model, message: "무슨 일이 있었는지 이야기해줄래? 네 얘기를 듣고 싶어.", time: "2025-07-08 19:21"),
        
        ChatMessage(role: .user, message: "회사에서 실수를 해서 팀장님한테 혼났어. 모두 앞에서...", time: "2025-07-08 19:23"),
        ChatMessage(role: .model, message: "그건 정말 속상했겠다. 사람들 앞이라 더 힘들었을 것 같아.", time: "2025-07-08 19:24"),
        
        ChatMessage(role: .user, message: "응... 뭔가 위축된 느낌이야. 내가 잘못한 건 맞지만 너무 창피했어.", time: "2025-07-08 19:25"),
        ChatMessage(role: .model, message: "그런 감정이 드는 건 당연해. 누구라도 비슷했을 거야.", time: "2025-07-08 19:26"),
        
        ChatMessage(role: .user, message: "요즘 자존감도 바닥이고, 무기력해지는 것 같아.", time: "2025-07-08 19:28"),
        ChatMessage(role: .model, message: "요즘 많이 지쳐 있었나 봐. 너 자신을 조금 더 돌봐줘야 할 시기일지도 몰라.", time: "2025-07-08 19:29"),
        
        ChatMessage(role: .user, message: "근데 쉴 수도 없어. 쉴 틈 없이 일만 하니까 더 번아웃이 오는 것 같아.", time: "2025-07-08 19:30"),
        ChatMessage(role: .model, message: "쉴 수 없다는 생각이 널 더 힘들게 하고 있을지도 몰라. 아주 잠깐이라도 쉬는 시간을 만들어보는 건 어때?", time: "2025-07-08 19:31"),
        
        ChatMessage(role: .user, message: "짧게라도 산책이라도 해볼까...?", time: "2025-07-08 19:32"),
        ChatMessage(role: .model, message: "좋은 생각이야. 햇빛을 쬐고 바람을 느끼면 생각보다 마음이 많이 가벼워질 수 있어.", time: "2025-07-08 19:33"),
        
        ChatMessage(role: .user, message: "너랑 얘기하니까 좀 위로가 돼. 고마워.", time: "2025-07-08 19:35"),
        ChatMessage(role: .model, message: "언제든지. 네 이야기를 들어주는 게 내 역할이니까. 오늘도 정말 잘 견뎠어.", time: "2025-07-08 19:36"),
        
        ChatMessage(role: .user, message: "내일은 조금 나아질 수 있을까?", time: "2025-07-08 19:37"),
        ChatMessage(role: .model, message: "물론이야. 아주 조금씩, 네 페이스대로 걸어가면 돼. 난 항상 네 편이야.", time: "2025-07-08 19:38")
    ]
}
