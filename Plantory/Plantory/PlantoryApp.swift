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
    
    init() {
        KakaoSDK.initSDK(appKey: Config.kakaoKey)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationRoutingView()
        }
    }
}
