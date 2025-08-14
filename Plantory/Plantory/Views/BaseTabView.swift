//
//  BaseTabView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct BaseTabView: View {

    // MARK: - Property
    
    enum TabItem: String, CaseIterable { case home, diary, terrarium, chat, profile }
    
    @State private var selectedTab: TabItem = .home
    @State private var isFilterSheetPresented: Bool = false
    @State private var hasShownTerrariumPopup = false
    @State private var isTerrariumPopupVisible = false
    @State private var showFlowerCompleteView = false  // 상태 관리
    @State private var terrariumVM: TerrariumViewModel? = nil

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
            
            if showFlowerCompleteView == true {
                if let vm = terrariumVM {
                    FlowerCompleteView(viewModel: vm)
                        .zIndex(11)
                }
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
            if terrariumVM == nil {
                terrariumVM = TerrariumViewModel(container: container)
            }
            UITabBar.appearance().backgroundColor = .white01
            UITabBar.appearance().unselectedItemTintColor = .black01
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
    }
    
    /// 각 탭에 해당하는 뷰
    @ViewBuilder
    private func tabView(tab: TabItem) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .diary:
            DiaryListView(isFilterSheetPresented: $isFilterSheetPresented)
        case .terrarium:
            Group {
                if let vm = terrariumVM {
                    TerrariumView(
                        viewModel: vm,
                        onInfoTapped: {
                            // 팝업을 표시하는 액션
                            isTerrariumPopupVisible = true
                        },
                        showFlowerCompleteView: $showFlowerCompleteView
                    )
                } else {
                    // 최초 한 번만 DI로 초기화
                    ProgressView()
                        .task {
                            if terrariumVM == nil {
                                terrariumVM = TerrariumViewModel(container: container)
                            }
                        }
                }
            }
        case .chat:
            ChatView(container: container)
        case .profile:
            MyPageView()
        }
    }
}
    
    
#Preview {
    BaseTabView()
        .environmentObject(makePreviewContainer())
}

#if DEBUG
private func makePreviewContainer() -> DIContainer {
    // TODO: 프로젝트의 DIContainer 초기화 방식에 맞게 수정하세요.
    // 예: DIContainer(authService: MockAuthService(), api: MockAPI(), ...)
    return DIContainer()
}
#endif
