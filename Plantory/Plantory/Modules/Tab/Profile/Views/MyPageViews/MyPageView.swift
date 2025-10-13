import SwiftUI
import Combine
import CombineMoya

// MARK: 메인 뷰
struct MyPageView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var popupManager: PopupManager
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var showSleepSheet = false
    @State private var showEmotionSheet = false
    @State private var showAlarmSheet = false
    @State private var showLogout = false
    @State private var isLoggingOut = false
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var weeklyResponse: WeeklySleepResponse? = nil
    
    @StateObject private var sleepViewModel: SleepStatsViewModel
    @StateObject private var statsVM: MyPageStatsViewModel
    
    init(container: DIContainer) {
        _sleepViewModel = StateObject(wrappedValue: SleepStatsViewModel(container: container))
        _statsVM = StateObject(wrappedValue: MyPageStatsViewModel(container: container))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HeaderView()
                
                Divider().background(.gray04)
                Spacer().frame(height: 45)
                
                // 프로필 관리 (VM에서 가공된 값만 바인딩)
                ProfileSection(
                    nickname: statsVM.nicknameText,
                    userCustomId: statsVM.userCustomIdText,
                    profileImageURL: statsVM.profileImageURL
                ) {
                    container.navigationRouter.push(.profileManage)
                }
                
                Spacer().frame(height: 45)
                Divider().background(.gray04)
                Spacer().frame(height: 24)
                
                // 통계 카드 (VM에서 생성한 stats)
                StatsSection(
                    stats: statsVM.stats,
                    actions: {
                        var dict: [UUID: () -> Void] = [:]
                        // 안전하게 인덱스 매핑하는 헬퍼
                                func set(_ i: Int, _ action: @escaping () -> Void) {
                                    guard statsVM.stats.indices.contains(i) else { return }
                                    dict[statsVM.stats[i].id] = action
                                }

                                // 0번: HomeView로 이동
                        set(0) { container.selectedTab = .home }

                                // 1번: 감정 시트
                                set(1) { showEmotionSheet = true }

                                // 2번: 수면 시트
                                set(2) { showSleepSheet = true }

                                // 3번: GardenView로 이동
                        set(3) { container.selectedTab = .terrarium }

                                return dict
                    }()
                )
                
                Spacer().frame(height: 24)
                
                // 메뉴 (스크랩 / 임시보관함 / 휴지통)
                MenuSection(
                    scrapAction:     { container.navigationRouter.push(.scrap) },
                    tempAction:      { container.navigationRouter.push(.tempStorage) },
                    trashAction:     { container.navigationRouter.push(.trash) },
                    logoutAction: {
                        // 로그아웃 판넬
                        popupManager.show {
                            PopUp(
                                title: "로그아웃 하시겠습니까?",
                                message: "로그아웃 시, 로그인 화면으로 돌아갑니다.",
                                confirmTitle: "로그아웃",
                                cancelTitle: "취소",
                                onConfirm: {
                                    statsVM.logout()
                                    container.navigationRouter.reset()
                                    sessionManager.isLoggedIn = false
                                },
                                onCancel: {
                                    popupManager.dismiss()
                                }
                            )
                        }
                    },
                    alarmAction: {
                        showAlarmSheet = true
                    }
                )
            }
            .padding(.vertical, 24)
        }
        .scrollIndicators(.hidden)
        .background(
            Color.adddiarybackground.ignoresSafeArea()
        )
        .sheet(isPresented: $showSleepSheet) {
            SleepStatsView(container: container)
                .presentationDetents([.fraction(0.9)])
        }
        .sheet(isPresented: $showEmotionSheet) {
            EmotionStatsView(container: container)
                .presentationDetents([.fraction(0.9)])
        }
        .sheet(isPresented: $showAlarmSheet) {
            AlarmView()
                .presentationDetents([.fraction(0.35)])
        }
        .navigationBarHidden(true)
        .loadingIndicator(statsVM.isLoading)
        .task {
            statsVM.fetch()
        }
    }
}

// MARK: — 헤더
struct HeaderView: View {
    var body: some View {
        HStack {
            Text("마이페이지")
                .font(.pretendardMedium(20))
                .foregroundStyle(.black01Dynamic)
            Spacer().frame(height: 17)
        }
        .padding(.horizontal, 28)
    }
}



// MARK: — 통계 섹션
struct StatsSection: View {
    let stats: [Stat]
    let actions: [UUID: () -> Void]
    private let columns = [
        GridItem(.flexible(), spacing: 21),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("통계")
                .font(.pretendardMedium(20))
                .foregroundStyle(.black01Dynamic)
                .padding(.horizontal, 28)

            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(stats) { stat in
                    StatCard(stat: stat, action: actions[stat.id] ?? {})
                }
            }
            .padding(.horizontal, 28)
        }
    }
}

// MARK: — 메뉴 섹션
struct MenuSection: View {
    let scrapAction: () -> Void
    let tempAction:  () -> Void
    let trashAction: () -> Void
    let logoutAction: () -> Void
    let alarmAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider().background(.gray04).padding(.vertical, 8)
            MenuRow(icon: "bookmark", title: "스크랩", action: scrapAction)
            MenuRow(icon: "scrap", title: "임시보관함", action: tempAction)
            MenuRow(icon: "delete", title: "휴지통", action: trashAction)
            MenuRow(icon: "logout", title: "로그아웃", action: logoutAction)
            Divider().padding(.vertical, 8)
            MenuRow(icon: "alarm", title: "알람 설정", action: alarmAction)

        }
        .background(Color.adddiarybackground)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.black01Dynamic)
                    .frame(width: 48, height: 48)
                Text(title)
                    .font(.pretendardRegular(18))
                    .foregroundStyle(.black01Dynamic)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    MyPageView(container: .init())
}
