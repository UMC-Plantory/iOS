import SwiftUI
import Charts

struct SleepStatsView: View {
    // 0 = Week, 1 = Month
    @State private var page: Int = 0

    @StateObject private var viewModel: SleepStatsViewModel

    init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: SleepStatsViewModel(container: container))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                
                WeekMonthPicker(selection: $page)
                    .padding(.top, 69)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                    .onChange(of: page) { _, new in
                        if new == 0 { viewModel.fetchWeekly() }
                        else        { viewModel.fetchMonthly() }
                    }

                Group {
                    if page == 0 {
                        weeklyArea
                    } else {
                        monthlyArea
                    }
                }
                .padding(.horizontal, 28)
                .animation(.default, value: page)
                .animation(.default, value: viewModel.isWeeklyEmpty)
                .animation(.default, value: viewModel.isMonthlyEmpty)
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .onAppear {
            if page == 0 { viewModel.fetchWeekly() }
            else         { viewModel.fetchMonthly() }
        }
    }

}

// MARK: - Weekly / Monthly Content
private extension SleepStatsView {

    @ViewBuilder
    var weeklyArea: some View {
        if !viewModel.weeklyLoaded {
            loadingView
        } else if viewModel.isWeeklyEmpty {
            NothingView(
                mainText: "주간 수면 통계 기록이 없어요",
                subText: "하루 하루 일기를 통해 수면 시간을 기록해 보세요!"
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
        } else {
            weeklyContent
        }
    }

    @ViewBuilder
    var monthlyArea: some View {
        if !viewModel.monthlyLoaded {
            loadingView
        } else if viewModel.isMonthlyEmpty {
            NothingView(
                mainText: "월간 수면 통계 기록이 없어요",
                subText: "한 달 동안의 수면 패턴을 모아볼 수 있어요!"
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
        } else {
            monthlyContent
        }
    }

    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }

    // ----- 실제 주간/월간 본문 -----
    var weeklyContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            WeekChartView(daily: viewModel.daily)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var monthlyContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            MonthChartView(weekly: viewModel.monthly)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // 공통 헤더(설명, 기간, 게이지)
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.comment)
                .font(.pretendardSemiBold(18))

            Text(viewModel.periodText)
                .font(.pretendardRegular(16))
                .foregroundColor(.gray09)

            HStack(alignment: .top) {
                Text(viewModel.averageComment)
                    .font(.pretendardRegular(12))
                    .foregroundColor(.green06)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 68, alignment: .topLeading)

                Spacer()

                SleepGaugeView(
                    progress: viewModel.progress,
                    label: viewModel.averageText
                )
                .frame(width: 120, height: 120)
            }
        }
    }
}

// MARK: - Preview
struct SleepStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DIContainer()
        SleepStatsView(container: container)
    }
}
