//
//  BaseTabView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct BaseTabView: View {

    // MARK: - Property
    
    @StateObject private var tabSelection = TabSelection()
    
    @State private var isTerrariumPopupVisible: Bool = false
    @State private var showFlowerComplete: Bool = false
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
            TabView(selection: $tabSelection.selectedTab) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    Tab(
                        "",
                        image: tabSelection.selectedTab == tab ? "\(tab.rawValue)_fill" : "\(tab.rawValue)",
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
                    tabSelection.selectedTab = .terrarium
                    terrariumVM.selectedTab = .myGarden
                    showFlowerComplete = false
                },
                onGoHome: {
                    tabSelection.selectedTab = .home
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
                            // Always return to My Garden tab when the popup closes
                            terrariumVM.selectedTab = .myGarden
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
        .onChange(of: showPlantPopup) { oldValue, isPresented in
            // Whenever the PlantPopupView toggles, force the terrarium internal tab to My Garden
            terrariumVM.selectedTab = .myGarden
            if isPresented {
                // Make sure the main tab is Terrarium when the popup shows
                tabSelection.selectedTab = .terrarium
            }
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
    }

    /// 각 탭에 해당하는 뷰
    @ViewBuilder
    private func tabView(tab: TabItem) -> some View {
        Group {
            switch tab {
            case .home:
                HomeView(container:container)
            case .diary:
                DiaryListView(container: container)
            case .terrarium:
                TerrariumView(
                    viewModel: terrariumVM,
                    onInfoTapped: { isTerrariumPopupVisible = true },
                    onFlowerComplete: { showFlowerComplete = true },
                    onPlantTap: { id in
                        // Ensure Terrarium tab and its internal tab are on My Garden when opening the popup
                        tabSelection.selectedTab = .terrarium
                        terrariumVM.selectedTab = .myGarden
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
        .environmentObject(container)
        .environmentObject(tabSelection)
    }
}

class TabSelection: ObservableObject {
    @Published var selectedTab: TabItem
    init(selectedTab: TabItem = .home) {
        self.selectedTab = selectedTab
    }
}
