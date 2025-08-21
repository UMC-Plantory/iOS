//
//  NavigationRoutingView.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//


import SwiftUI

struct NavigationRoutingView: View {
    @StateObject private var container: DIContainer = .init()
    @State private var isFilterSheetPresented = false
    var body: some View {
        NavigationStack(path: $container.navigationRouter.path) {
            LoginView(container: container)
                .environmentObject(container)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    Group {
                        destinationView(for: destination)
                    }
                }
        }
        .environmentObject(container) // 한 번만 주입하면 충분
    }

    
    
    // MARK: - Destination 헬퍼 (타입 추론 안정화)
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        // 로그인/회원가입
        case .login:
            LoginView(container: container)
        case .permit:
            PermitView(container: container)
        case .policy(let num):
            PolicyView(num: num)
        case .profileInfo:
            ProfileInfoView(container: container)

        // Tab 뷰
        case .baseTab:
            BaseTabView(terrariumVM: TerrariumViewModel(container: container))

        // 마이페이지
        case .scrap:
            ScrapView()
        case .tempStorage:
            TempStorageView(container: container)
        case .trash:
            TrashView(container: container)
        case .emotionStats:
            EmotionStatsView(container: container)
        case .profileManage:
            ProfileManageView(container: container)

        // 다이어리 뷰
        case .diary:
            DiaryListView( isFilterSheetPresented: $isFilterSheetPresented,container: container)
            
        case .diaryDetail(let diaryId):
                   DiaryCheckView(diary: DiaryEntry(
                    id: diaryId,
                    date: Date(),
                    title: "",
                    content: "",
                    emotion: .HAPPY,
                    isScrapped: false
                ),
                summary: DiarySummary(
                    diaryId: diaryId,
                    diaryDate: "",
                    title: "",
                    status: "NORMAL",
                    emotion: "",
                    content: ""
                ),
                isDeleteSheetPresented: .constant(false),
                container: container)

        }
    }
}
#Preview {
    NavigationRoutingView()
}
