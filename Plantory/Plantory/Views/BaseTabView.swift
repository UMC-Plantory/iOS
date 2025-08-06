//
//  BaseTabView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct BaseTabView: View {
    enum TabItem: String, CaseIterable {
        case home, diary, terrarium, chat, profile
    }

    @State private var selectedTab: TabItem = .home
    @State private var hasShownTerrariumPopup = false
    @State private var isTerrariumPopupVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                Tab(
                    "",
                    image: selectedTab == .home ? "Home_fill" : "Home",
                    value: TabItem.home
                ) {
                    HomeView()
                }
                
                Tab(
                    "",
                    image: selectedTab == .diary ? "Diary_fill" : "Diary",
                    value: TabItem.diary
                ) {
                    DiaryView()
                }
                
                Tab(
                    "",
                    image: selectedTab == .terrarium ? "Terrarium_fill" : "Terrarium",
                    value: TabItem.terrarium
                ) {
                    TerrariumView()
                }
                
                Tab(
                    "",
                    image: selectedTab == .chat ? "Chat_fill" : "Chat",
                    value: TabItem.chat
                ) {
                    ChatView()
                }
                
                Tab(
                    "",
                    image: selectedTab == .profile ? "Profile_fill" : "Profile",
                    value: TabItem.profile
                ) {
                    ProfileView()
                }
            }

            if isTerrariumPopupVisible {
                TerrariumPopup(isVisible: $isTerrariumPopupVisible)
                    .zIndex(10)
            }

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
}

#Preview {
    BaseTabView()
}
