//
//  NavigationRoutingView.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import SwiftUI

/// 앱 내에서 특정 화면으로의 이동을 처리하는 라우팅 뷰입니다.
struct NavigationRoutingView: View {
    
    @State private var router = NavigationRouter()
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView()
                .environment(router)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    Group {
                        switch destination {
                        case .login:
                            LoginView()
                        case .permit:
                            PermitView()
                        case .baseTab:
                            BaseTabView()
                        }
                    }
                    .environment(router)
                }
        }
    }
}

#Preview {
    NavigationRoutingView()
}
