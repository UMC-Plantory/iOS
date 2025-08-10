//
//  BaseTabView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct BaseTabView: View {

    // MARK: - Property
    
    @State private var selectedTab: TabItem = .home

    @State private var hasShownTerrariumPopup = false
    @State private var isTerrariumPopupVisible = false
    
    /// 의존성 주입을 위한 DI 컨테이너
    @EnvironmentObject var container: DIContainer

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    Tab(
                        "",
                        image: selectedTab == tab ? "\(tab.rawValue)_fill" : "\(tab.rawValue)",
                        value: tab,
                        content: {
                            tabView(tab: tab)
                        }
                    )
                }
            }

            if isTerrariumPopupVisible {
                TerrariumPopup(isVisible: $isTerrariumPopupVisible)
                    .zIndex(10)
            }
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray.opacity(0.4))
                    .frame(height: 1)
                Spacer().frame(height: 49)
            }
            .allowsHitTesting(false)
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = .white01
            UITabBar.appearance().unselectedItemTintColor = .black01
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .terrarium && !hasShownTerrariumPopup {
                isTerrariumPopupVisible = true
                hasShownTerrariumPopup = true
            }
        }
    }
    
    /// 각 탭에 해당하는 뷰
    @ViewBuilder
    private func tabView(tab: TabItem) -> some View {
        Group {
            switch tab {
            case .home:
                HomeView()
            case .diary:
                DiaryView()
            case .terrarium:
                TerrariumView()
            case .chat:
                ChatView(container: container)
            case .profile:
                ProfileView()
            }
        }
        .environmentObject(container)
    }
}

#Preview {
    BaseTabView()
}
