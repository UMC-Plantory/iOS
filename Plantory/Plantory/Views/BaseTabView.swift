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
    
    @State private var isFilterSheetPresented: Bool = false
    @State private var isTerrariumPopupVisible: Bool = false
    @State private var showFlowerComplete:Bool = false
    @State private var showPlantPopup = false
    @State private var selectedTerrariumId: Int? = nil
    @State private var terrariumVM: TerrariumViewModel
    @State private var plantPopupVM: PlantPopupViewModel

    /// 의존성 주입을 위한 DI 컨테이너
    @EnvironmentObject var container: DIContainer

    init(terrariumVM: TerrariumViewModel) {
        _terrariumVM = State(initialValue: terrariumVM)
        _plantPopupVM = State(initialValue: PlantPopupViewModel(container: terrariumVM.container))
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
            .allowsHitTesting(!showPlantPopup)
            
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
        .overlay(alignment: .center) {
            if showPlantPopup {
                ZStack {
                    // Dimmed background to block taps behind the popup
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    PlantPopupView(
                        viewModel: plantPopupVM,
                        onClose: {
                            showPlantPopup = false
                            selectedTerrariumId = nil
                            plantPopupVM.close()
                        }
                    )
                    .environmentObject(container)
                    .transition(.opacity.combined(with: .scale))
                }
                .zIndex(11)
            }
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

            TerrariumView()
        case .chat:
            ChatView(container: container)
        case .profile:
            MyPageView()
        }
     }
        .environmentObject(container)
  
            TerrariumView(
                viewModel: terrariumVM,
                onInfoTapped: { isTerrariumPopupVisible = true },
                onFlowerComplete: { showFlowerComplete = true },
                onPlantTap: { id in
                    selectedTerrariumId = id
                    plantPopupVM.open(terrariumId: id)
                    showPlantPopup = true
                }
            )
        case .chat:
            ChatView(container: container)
        case .profile:
            MyPageView(container: container)

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
