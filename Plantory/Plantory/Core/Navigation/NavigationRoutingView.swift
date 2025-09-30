//
//  NavigationRoutingView.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//


import SwiftUI
import FirebaseMessaging


/// 앱 내에서 특정 화면으로의 이동을 처리하는 라우팅 뷰입니다.
struct NavigationRoutingView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationStack(path: $container.navigationRouter.path) {
            BaseTabView()
                .environmentObject(container)
                .environmentObject(sessionManager)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    Group {
                        switch destination {
                        // 로그인, 회원가입 뷰
                        case .login:
                            LoginView(container: container, sessionManager: sessionManager)
                        case .permit:
                            PermitView(container: container)
                        case .policy(let num):
                            PolicyView(num: num)
                        case .profileInfo:
                            ProfileInfoView(container: container)
                                .environmentObject(sessionManager)
                            
                        case .addDiary(let date):
                            AddDiaryView(container: container, date: date)
                            
                        // Tab 뷰
                        case .baseTab:
                            BaseTabView()
                            
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
                                .environmentObject(sessionManager)
                            
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
        .onAppear {
            Messaging.messaging().token { token, error in
              if let error = error {
                print("Error fetching FCM registration token: \(error)")
              } else if let token = token {
                print("FCM registration token: \(token)")
              }
            }
        }
    }
}


#Preview {
    NavigationRoutingView()
}
