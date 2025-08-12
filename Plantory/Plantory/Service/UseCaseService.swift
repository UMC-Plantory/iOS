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
    let authService: AuthService
    let chatService: ChatService
    let terrariumService: TerrariumService
    let terrariumService: TerrariumService
    
    init() {
        self.kakaoManager = .init()
        self.authService = .init()
        self.chatService = .init()
        self.terrariumService = .init()
        self.terrariumService = .init()
    }
}
