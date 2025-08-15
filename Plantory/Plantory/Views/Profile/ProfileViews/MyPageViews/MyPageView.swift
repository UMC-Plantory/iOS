import SwiftUI
import Combine
import CombineMoya

// MARK: 메인 뷰
struct MyPageView: View {
    private let container: DIContainer
    
    @State private var showSleepSheet = false
    @State private var showEmotionSheet = false
    @State private var showLogout = false
    @State private var isLoggingOut = false
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var weeklyResponse: WeeklySleepResponse? = nil
    
    @StateObject private var sleepViewModel: SleepStatsViewModel
    @StateObject private var statsVM: MyPageStatsViewModel
    
    init(container: DIContainer) {
        self.container = container
        _sleepViewModel = StateObject(wrappedValue: SleepStatsViewModel(container: container))
        _statsVM = StateObject(wrappedValue: MyPageStatsViewModel(container: container))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HeaderView()
                
                Divider()
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
                Divider()
                Spacer().frame(height: 24)
                
                // 통계 카드 (VM에서 생성한 stats)
                StatsSection(
                    stats: statsVM.stats,
                    actions: {
                        var dict: [UUID: () -> Void] = [:]
                        if statsVM.stats.indices.contains(1) {
                            dict[statsVM.stats[1].id] = { showEmotionSheet = true }
                        }
                        if statsVM.stats.indices.contains(2) {
                            dict[statsVM.stats[2].id] = { showSleepSheet = true }
                        }
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
                        withAnimation(.spring()) { showLogout = true }
                    }
                )
            }
            .padding(.vertical, 24)
        }
        .sheet(isPresented: $showSleepSheet) {
            SleepStatsView(container: container)
        }
        .sheet(isPresented: $showEmotionSheet) {
            EmotionStatsView(container: container)
        }
        .overlay {
            if showLogout {
                BlurBackground()
                    .onTapGesture {
                        withAnimation(.spring()) { showLogout = false }
                    }
                
                PopUp(
                    title: "로그아웃 하시겠습니까?",
                    message: "로그아웃 시, 로그인 화면으로 돌아갑니다.",
                    confirmTitle: "로그아웃",
                    cancelTitle: "취소",
                    onConfirm: {
                        statsVM.logout()
                        container.navigationRouter.reset()
                    },
                    onCancel: { withAnimation(.spring()) { showLogout = false } }
                )
            }
        }
        .onChange(of: statsVM.didLogout, initial: false) { _, done in
            if done {
                showLogout = false
            }
        }
        .navigationBarHidden(true)
        .loadingIndicator(statsVM.isLoading)
    }
}

// MARK: — 헤더
struct HeaderView: View {
    var body: some View {
        HStack {
            Text("마이페이지")
                .font(.pretendardMedium(20))
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

    var body: some View {
        VStack(spacing: 0) {
            Divider().padding(.vertical, 8)
            MenuRow(icon: "bookmark", title: "스크랩", action: scrapAction)
            MenuRow(icon: "scrap", title: "임시보관함", action: tempAction)
            MenuRow(icon: "delete", title: "휴지통", action: trashAction)
            MenuRow(icon: "logout", title: "로그아웃", action: logoutAction)
        }
        .background(Color.white)
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
                    .frame(width: 48, height: 48)
                Text(title)
                    .font(.pretendardRegular(18))
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
