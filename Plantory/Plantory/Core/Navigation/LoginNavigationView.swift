//
//  LoginNavigationView.swift
//  Plantory
//
//  Created by 주민영 on 11/11/25.
//

import SwiftUI

struct LoginNavigationView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var sessionManager: SessionManager

    // 로그인 플로우 전용 라우터(ViewModel)
    @StateObject private var loginRouter: LoginRouter = .init()

    var body: some View {
        NavigationStack(path: $loginRouter.path) {
            LoginView(container: container, sessionManager: sessionManager, loginRouter: loginRouter)
                .navigationDestination(for: LoginDestination.self) { route in
                    switch route {
                    case .permit:
                        PermitView(container: container, loginRouter: loginRouter)
                            .environmentObject(loginRouter)
                    case .policy(let num):
                        PolicyView(num: num)
                            .environmentObject(loginRouter)
                    case .profileInfo:
                        ProfileInfoView(container: container)
                            .environmentObject(sessionManager)
                            .environmentObject(loginRouter)
                    }
                }
        }
    }
}
