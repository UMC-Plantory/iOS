    //
    //  NavigationRoutingView.swift
    //  Plantory
    //
    //  Created by 주민영 on 7/17/25.
    //

    import SwiftUI

    /// 앱 내에서 특정 화면으로의 이동을 처리하는 라우팅 뷰입니다.
    struct NavigationRoutingView: View {
        
        /// DIContainer 의존성 주입
        @StateObject private var container: DIContainer = .init()
        
        // MARK: - Body
        var body: some View {
            NavigationStack(path: $container.navigationRouter.path) {
                LoginView(container: container)
                    .environmentObject(container)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        Group {
                            switch destination {
                            case .login:
                                LoginView(container: container)
                            case .permit:
                                PermitView(container: container)
                            case .policy(let num):
                                PolicyView(num: num)
                            case .profileInfo:
                                ProfileInfoView(container: container)
                            case .addDiary():       AddDiaryView(container: container)
                            case .home:
                                HomeView(container:container)

                            
                            case .baseTab:
                                BaseTabView()
                                
                            // 마이페이지
                            case .scrap:
                                ScrapView()
                            case .tempStorage:
                                TempStorageView()
                            case .trash:
                                TrashView()
                            case .emotionStats:
                                EmotionStatsView()
                            case .profileManage:
                                ProfileManageView()
                            
                            
                            
                            }
                        }
                        .environmentObject(container)
                    }
            }
        }
    }

    #Preview {
        NavigationRoutingView()
    }
