//
//  BaseTabView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct BaseTabView: View {

    /// 의존성 주입을 위한 DI 컨테이너
    @EnvironmentObject var container: DIContainer
    
    @EnvironmentObject var sessionManager: SessionManager
    
    /// 팝업을 공통으로 관리하기 위한 Manager
    @StateObject private var popupManager = PopupManager()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $container.selectedTab) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    Tab(
                        "",
                        image: container.selectedTab == tab ? "\(tab.rawValue)_fill" : "\(tab.rawValue)",
                        value: tab,
                        content: {
                            tabView(tab: tab)
                        }
                    )
                }
            }
            .allowsHitTesting(!popupManager.isPresented)
            
            if popupManager.isPresented {
                ZStack {
                    BlurBackground()
                        .onTapGesture { withAnimation { popupManager.dismiss() } }
                    
                    popupManager.popupContent
                        .transition(.opacity.combined(with: .scale))
                }
                .zIndex(99)
            }
        }
        .tint(.black01Dynamic)
        .toolbarBackground(.white01Dynamic, for: .tabBar)
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
    }

    /// 각 탭에 해당하는 뷰
    @ViewBuilder
    private func tabView(tab: TabItem) -> some View {
        Group {
            switch tab {
            case .home:
                HomeView(container: container)
            case .diary:
                DiaryListView(container: container)
            case .terrarium:
                TerrariumView(container: container)
            case .chat:
                ChatView(container: container)
            case .profile:
                MyPageView(container: container)
                    .environmentObject(sessionManager)
            }
        }
        .environmentObject(container)
        .environmentObject(popupManager)
    }
}

#Preview {
    BaseTabView()
        .environmentObject(DIContainer())
}
