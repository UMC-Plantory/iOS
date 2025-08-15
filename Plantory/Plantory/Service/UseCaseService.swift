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
    let imageService: ImageService
    let authService: AuthService
    let chatService: ChatService

    let homeService: HomeService

    let terrariumService: TerrariumService
    let profileService: ProfileService

    
    init() {
        self.kakaoManager = .init()
        self.appleManager = .init()
        self.imageService = .init()
        self.authService = .init()
        self.chatService = .init()

        self.homeService = .init()

        self.terrariumService = .init()
        self.profileService = .init()
    }
}
