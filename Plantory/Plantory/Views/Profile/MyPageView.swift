import SwiftUI

// MARK: 메인 뷰
struct MyPageView: View {
    private let stats: [Stat] = [
        Stat(value: "35일", label: "연속 기록"),
        Stat(value: "5개", label: "누적 감정 기록 횟수"),
        Stat(value: "6h 53m", label: "평균 수면 시간"),
        Stat(value: "4개", label: "피어난 꽃의 수")
    ]
    
    @EnvironmentObject var container: DIContainer

    @State private var showSleepSheet = false
    @State private var showEmotionSheet = false
    @State private var showLogout = false
    @State private var weeklyResponse: WeeklySleepResponse? = nil
    private let SleepViewModel = SleepStatsViewModel()
    
    var body: some View {
            ScrollView {
                VStack {
                    HeaderView()
                    
                    Divider()
                    
                    Spacer().frame(height: 45)
                    
                    // 프로필 관리
                    ProfileSection {
                        container.navigationRouter.push(.profileManage)
                    }
                    
                    Spacer().frame(height: 45)
                    
                    Divider()
                    
                    Spacer().frame(height: 24)
                    // 통계 카드
                    StatsSection(
                        stats: stats,
                        actions: [
                            stats[1].id: { showEmotionSheet = true },
                            stats[2].id: { showSleepSheet = true }
                        ]
                    )
                    
                    Spacer().frame(height: 24)
                    
                    // 메뉴 (스크랩 / 임시보관함 / 휴지통)
                    MenuSection(
                        scrapAction:     { container.navigationRouter.push(.scrap) },
                        tempAction:      { container.navigationRouter.push(.tempStorage) },
                        trashAction:     { container.navigationRouter.push(.trash) }, logoutAction: {
                            // 로그아웃 판넬
                            showLogout = true
                        }
                    )
                }
                .padding(.vertical, 24)
            }
            .sheet(isPresented: $showSleepSheet) {
                SleepStatsView(viewModel: SleepViewModel)
            }
            .sheet(isPresented: $showEmotionSheet) {
                 EmotionStatsView(viewModel: EmotionStatsViewModel())
            }
            .overlay {
                if showLogout {
                    PopUp(
                        title: "로그아웃 하시겠습니까?",
                        message: "로그아웃 시, 로그인 화면으로 돌아갑니다.",
                        confirmTitle: "로그아웃",
                        cancelTitle: "취소",
                        onConfirm: {
                            // 삭제 로직
                            showLogout = false
                        },
                        onCancel: {
                            showLogout = false
                        }
                    )
                }
            }
            .navigationBarHidden(true)
        }
    }

// MARK: — 헤더
private struct HeaderView: View {
    var body: some View {
        HStack {
            Text("마이페이지")
                .font(.pretendardMedium(20))
            Spacer().frame(height: 17)
        }
        .padding(.horizontal, 28)
    }
}

// MARK: — 프로필 섹션
private struct ProfileSection: View {
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 18) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 64, height: 64)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("송이")
                    .font(.pretendardMedium(20))
                Text("songe2")
                    .font(.pretendardRegular(16))
                    .foregroundColor(.gray09)
            }
            Spacer()
            Button(action: action) {
                Text("프로필 관리")
                    .font(.pretendardMedium(16))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.green04)
                    .cornerRadius(5)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 28)
    }
}

// MARK: — 통계 섹션
private struct StatsSection: View {
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

// MARK: — 통계 카드
private struct StatCard: View {
    let stat: Stat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(stat.value)
                    .font(.pretendardMedium(20))
                Text(stat.label)
                    .font(.pretendardRegular(16))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green02)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



// MARK: — 메뉴 섹션
private struct MenuSection: View {
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

private struct MenuRow: View {
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
struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
