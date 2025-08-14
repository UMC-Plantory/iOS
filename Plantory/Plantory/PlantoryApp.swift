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
        KakaoSDK.initSDK(appKey: "77e9dac04fcf399304279a570d95f904")
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationRoutingView()
        }
    }
}
