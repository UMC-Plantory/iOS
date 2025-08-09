//
//  UseCaseService.swift
//  Plantory
//
//  Created by 주민영 on 7/25/25.
//

import Foundation

/// API 서비스 모델
class UseCaseService {
    
    let kakaoManager: KakakoLoginManager
    let appleManager: AppleLoginManager
    let authService: AuthService
    let chatService: ChatService
    
    init() {
        self.kakaoManager = .init()
        self.appleManager = .init()
        self.authService = .init()
        self.chatService = .init()
    }
}
