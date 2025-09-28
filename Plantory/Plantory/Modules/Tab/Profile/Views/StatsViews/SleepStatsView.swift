import SwiftUI
import Charts

struct SleepStatsView: View {
    @StateObject private var viewModel: SleepStatsViewModel
    @State private var page: Int = 0    // 0 = Week, 1 = Month

    init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: SleepStatsViewModel(container: container))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer().frame(height: 45)
            
            WeekMonthPicker(selection: $page)
                .frame(maxWidth: .infinity, alignment: .center)
                .onChange(of: page) { old, new in
                    if new == 0 { viewModel.fetchWeekly() }
                    else       { viewModel.fetchMonthly() }
                }


            // ——— 여기부터 텍스트 섹션 ———
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.comment)
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(.black01Dynamic)
                Text(viewModel.periodText)
                    .font(.pretendardRegular(16))
                    .foregroundColor(.gray09Dynamic)
                HStack {
                        Text(viewModel.averageComment)
                            .font(.pretendardRegular(12))
                            .foregroundColor(.green06Dynamic)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(minHeight: 68, alignment: .topLeading)
                    Spacer()
                    SleepGaugeView(
                        progress: viewModel.progress,
                        label: viewModel.averageText
                    )
                    .frame(width: 120, height: 120)
                    .offset(y: 50)
                }
                .offset(y: -20)
            }
            
            // ——— 차트 뷰 ———
            if page == 0 {
                WeekChartView(daily: viewModel.daily)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: 50)
            } else {
                MonthChartView(weekly: viewModel.monthly)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: 50)
            }

            Spacer()
        }
        .padding(.horizontal, 28) // ③ 전체 좌우 여백
        .background(
            Color.white01Dynamic.ignoresSafeArea()
        )
    }
}


// MARK: - Preview
struct SleepStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DIContainer() // 기본 이니셜라이저가 있다면
        SleepStatsView(container: container)
    }
}
