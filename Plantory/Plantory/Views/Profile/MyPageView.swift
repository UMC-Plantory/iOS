import SwiftUI

final class MyPageViewModel: ObservableObject {
    @Published var stats: [Stat]
    @Published var path = NavigationPath()
    @Published var showSleepSheet = false
    let previewResponse: WeeklySleepResponse

    init() {
        // 초기 통계 데이터
        self.stats = [
            Stat(value: "35일", label: "연속 기록"),
            Stat(value: "5개", label: "누적 감정 기록 횟수"),
            Stat(value: "6h 53m", label: "평균 수면 시간"),
            Stat(value: "4개", label: "피어난 꽃의 수")
        ]
        // 샘플 응답 디코딩
        let decoder = JSONDecoder.customDateDecoder
        if let decoded = try? decoder.decode(WeeklySleepResponse.self, from: SleepAPI.weeklyStats.sampleData) {
            self.previewResponse = decoded
        } else {
            self.previewResponse = WeeklySleepResponse(
                startDate: Date(),
                endDate: Date(),
                daily: [],
                average: .init(hours: 0, minutes: 0)
            )
        }
    }

    /// 통계 카드 선택 처리
    func didTapStat(_ stat: Stat) {
        if stat.id == stats[1].id {
            path.append(MyPageRoute.emotionStats)
        } else if stat.id == stats[2].id {
            showSleepSheet.toggle()
        }
    }
}


// File: MyPageView.swift
import SwiftUI

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                VStack(spacing: 32) {
                    HeaderView()
                    ProfileSection(action: { viewModel.path.append(MyPageRoute.profileManage) })
                    StatsSection(stats: viewModel.stats, onTap: viewModel.didTapStat)
                    MenuSection(
                        scrapAction: { viewModel.path.append(MyPageRoute.scrap) },
                        tempAction:  { viewModel.path.append(MyPageRoute.tempStorage) },
                        trashAction: { viewModel.path.append(MyPageRoute.trash) }
                    )
                }
                .padding(.vertical, 24)
            }
            .sheet(isPresented: $viewModel.showSleepSheet) {
                SleepStatsView(response: viewModel.previewResponse)
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


// File: MyPageSubViews.swift
import SwiftUI

private struct HeaderView: View {
    var body: some View {
        HStack {
            Text("마이페이지").font(.pretendardMedium(20))
            Spacer()
        }
        .padding(.horizontal, 28)
    }
}

private struct ProfileSection: View {
    let action: () -> Void
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 4) {
                Text("송이").font(.pretendardMedium(20))
                Text("songe2").font(.pretendardRegular(16)).foregroundColor(.gray06)
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
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 28)
    }
}

private struct StatsSection: View {
    let stats: [Stat]
    let onTap: (Stat) -> Void
    private let columns = [GridItem(.flexible(), spacing: 21), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("통계").font(.pretendardMedium(20)).padding(.horizontal, 28)
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(stats) { stat in
                    StatCard(stat: stat, action: { onTap(stat) })
                }
            }
            .padding(.horizontal, 28)
        }
    }
}

private struct StatCard: View {
    let stat: Stat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(stat.value).font(.pretendardMedium(20))
                Text(stat.label).font(.pretendardRegular(16))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green02)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)
        }
        .buttonStyle(.plain)
    }
}

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
                Image(systemName: icon).font(.title3)
                Text(title).font(.pretendardRegular(16))
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
