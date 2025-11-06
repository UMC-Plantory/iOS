//
//  PlantoryApp.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct PlantoryApp: App {
    
    @StateObject private var container: DIContainer = .init()
    
    @StateObject private var sessionManager = SessionManager()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        KakaoSDK.initSDK(appKey: Config.kakaoKey)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
               .environmentObject(container)
               .environmentObject(sessionManager)
               .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
                   // refresh 실패 → 자동 로그아웃 처리
                   sessionManager.logout()
               }
               .onOpenURL(perform: { url in
                   if (AuthApi.isKakaoTalkLoginUrl(url)) {
                       _ = AuthController.handleOpenUrl(url: url)
                   }
               })
        }
        .modelContainer(for: ReplyStateData.self)
    }
}
