import SwiftUI

// MARK: 메인 뷰
struct MyPageView: View {
    private let stats: [Stat] = [
        Stat(value: "35일", label: "연속 기록"),
        Stat(value: "5개", label: "누적 감정 기록 횟수"),
        Stat(value: "6h 53m", label: "평균 수면 시간"),
        Stat(value: "4개", label: "피어난 꽃의 수")
    ]
    
    @State private var path = NavigationPath()
    @State private var showSleepSheet = false
    @State private var weeklyResponse: WeeklySleepResponse? = nil
    private let SleepViewModel = SleepStatsViewModel()
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 32) {
                    HeaderView()
                    
                    // 프로필 관리
                    ProfileSection {
                        path.append(MyPageRoute.profileManage)
                    }
                    
                    Divider()
                    
                    // 통계 카드
                    StatsSection(
                        stats: stats,
                        actions: [
                            stats[1].id: { path.append(MyPageRoute.emotionStats) },
                            stats[2].id: { showSleepSheet = true }
                        ]
                    )
                    
                    // 메뉴 (스크랩 / 임시보관함 / 휴지통)
                    MenuSection(
                        scrapAction:     { path.append(MyPageRoute.scrap) },
                        tempAction:      { path.append(MyPageRoute.tempStorage) },
                        trashAction:     { path.append(MyPageRoute.trash) }
                    )
                }
                .padding(.vertical, 24)
            }
            .sheet(isPresented: $showSleepSheet) {
                SleepStatsView(viewModel: SleepViewModel)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: MyPageRoute.self) { route in
                switch route {
                case .scrap:          ScrapView()
                case .tempStorage:    TempStorageView()
                case .trash:          TrashView()
                case .emotionStats:   EmotionStatsView()
                case .profileManage:  ProfileManageView()
                }
            }
        }
    }
}

// MARK: — 헤더
private struct HeaderView: View {
    var body: some View {
        HStack {
            Text("마이페이지")
                .font(.pretendardMedium(20))
            Spacer()
        }
        .padding(.horizontal, 28)
    }
}

// MARK: — 프로필 섹션
private struct ProfileSection: View {
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 64, height: 64)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("송이")
                    .font(.pretendardMedium(20))
                Text("songe2")
                    .font(.pretendardRegular(16))
                    .foregroundColor(.gray06)
            }
            Spacer()
            Button(action: action) {
                Text("프로필 관리")
                    .font(.pretendardMedium(16))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.green04)
                    .cornerRadius(8)
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
        VStack(alignment: .leading, spacing: 16) {
            Text("통계")
                .font(.pretendardMedium(20))
                .padding(.horizontal, 28)
            
            LazyVGrid(columns: columns, spacing: 25) {
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
    
    var body: some View {
        VStack(spacing: 0) {
            Divider().padding(.vertical, 8)
            MenuRow(icon: "bookmark", title: "스크랩", action: scrapAction)
            MenuRow(icon: "tray.and.arrow.down", title: "임시보관함", action: tempAction)
            MenuRow(icon: "trash", title: "휴지통", action: trashAction)
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.pretendardRegular(16))
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
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
