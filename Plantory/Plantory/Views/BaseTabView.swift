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
    @State private var isTerrariumPopupVisible: Bool = false
    @State private var showFlowerComplete:Bool = false
    @State private var terrariumVM: TerrariumViewModel

    /// 의존성 주입을 위한 DI 컨테이너
    @EnvironmentObject var container: DIContainer

    init(terrariumVM: TerrariumViewModel) {
        _terrariumVM = State(initialValue: terrariumVM)
    }

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
        .fullScreenCover(isPresented: $showFlowerComplete, onDismiss: {
            terrariumVM.fetchTerrarium()
        }) {
            FlowerCompleteView(
                viewModel: terrariumVM,
                onGoToGarden: {
                    selectedTab = .terrarium
                    terrariumVM.selectedTab = .myGarden
                    showFlowerComplete = false
                },
                onGoHome: {
                    selectedTab = .home
                    showFlowerComplete = false 
                }
            )
            .environmentObject(container)
            .onAppear {
                // FlowerCompleteView가 나타날 때 갱신
                terrariumVM.fetchTerrarium()
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
            TerrariumView(
                viewModel: terrariumVM,
                onInfoTapped: { isTerrariumPopupVisible = true },
                onFlowerComplete: { showFlowerComplete = true }
            )
        case .chat:
            ChatView(container: container)
        case .profile:
            MyPageView()
        }
    }
}
    
    
// MARK: - Preview
#Preview {
    let previewContainer = makePreviewContainer()
    let previewTerrariumVM = TerrariumViewModel(container: previewContainer)
    return BaseTabView(terrariumVM: previewTerrariumVM)
        .environmentObject(previewContainer)
}

#if DEBUG
private func makePreviewContainer() -> DIContainer {
    // TODO: 프로젝트의 DIContainer 초기화 방식에 맞게 수정하세요.
    // 예: DIContainer(authService: MockAuthService(), api: MockAPI(), ...)
    return DIContainer()
}
#endif
