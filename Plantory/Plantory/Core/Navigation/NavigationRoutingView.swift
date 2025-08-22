//
//  NavigationRoutingView.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//


import SwiftUI


/// 앱 내에서 특정 화면으로의 이동을 처리하는 라우팅 뷰입니다.
struct NavigationRoutingView: View {
    @StateObject private var container: DIContainer = .init()
    @State private var isFilterSheetPresented = false
    var body: some View {
        NavigationStack(path: $container.navigationRouter.path) {
            LoginView(container: container)
                .environmentObject(container)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    Group {
                        switch destination {
                        // 로그인, 회원가입 뷰
                        case .login:
                            LoginView(container: container)
                        case .permit:
                            PermitView(container: container)
                        case .policy(let num):
                            PolicyView(num: num)
                        case .profileInfo:
                            ProfileInfoView(container: container)
                            
                        case .addDiary(let date):
                            AddDiaryView(container: container, date: date)
                            
                        // Tab 뷰
                        case .baseTab:
                            BaseTabView(terrariumVM: TerrariumViewModel(container: container))
                            
                        // 마이페이지
                        case .scrap:
                            ScrapView(container: container)
                        case .tempStorage:
                            TempStorageView(container: container)
                        case .trash:
                            TrashView(container: container)
                        case .emotionStats:
                            EmotionStatsView(container: container)
                        case .profileManage:
                            ProfileManageView(container: container)
                            
                        case .diarySearch:
                            DiarySearchView(container: container)
                        case .diaryDetail(let diaryId):
                            DiaryCheckView(
                                diaryId: diaryId,
                                container: container
                            )
                        }
                    }
                }
        }
        .environmentObject(container)
    }
}


#Preview {
    NavigationRoutingView()
}
