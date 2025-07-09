import SwiftUI

struct SleepStatsView: View {
    @StateObject private var viewModel: SleepStatsViewModel
    @State private var page: Int = 0    // 0 = Week, 1 = Month

    init(viewModel: SleepStatsViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            WeekMonthPicker(selection: $page)
                .onChange(of: page) { oldValue, newValue in
                    if newValue == 0 {
                        viewModel.fetchWeekly()
                    } else {
                        viewModel.fetchMonthly()
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.periodText)
                    .font(.pretendardRegular(14))
                    .foregroundColor(.gray06)
                Text(viewModel.averageText)
                    .font(.pretendardSemiBold(32))
                Text(viewModel.averageComment)
                    .font(.pretendardRegular(14))
            }
            .padding(.horizontal, 28)

            if page == 0 {
                WeekChartView(daily: viewModel.daily)
            } else {
                MonthChartView(weekly: viewModel.weekly)
            }

            Spacer()
        }
    }
}


// MARK: - 페이징 탭
struct WeekMonthPicker: View {
    @Binding var selection: Int    // 0 = Week, 1 = Month
    private let titles = ["Week", "Month"]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<titles.count, id: \.self) { idx in
                    Button {
                        withAnimation { selection = idx }
                    } label: {
                        Text(titles[idx])
                            .font(.pretendardMedium(16))
                            .foregroundColor(selection == idx ? .black : .gray06)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            HStack(spacing: 0) {
                ForEach(0..<titles.count, id: \.self) { idx in
                    Rectangle()
                        .fill(selection == idx ? Color.black : Color.clear)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 28)
    }
}

// MARK: - 주간 막대 차트
struct WeekChartView: View {
    let daily: [DailySleep]

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            ForEach(daily) { day in
                VStack(spacing: 4) {
                    if let h = day.hours, let m = day.minutes {
                        let total = Double(h) + Double(m)/60
                        Capsule()
                            .fill(Color.green04)
                            .frame(width: 20, height: CGFloat((total/12)*100))
                    } else {
                        Capsule()
                            .fill(Color.gray06.opacity(0.2))
                            .frame(width: 20, height: 4)
                    }
                    Text(day.weekday)
                        .font(.pretendardRegular(12))
                    Text("\(Calendar.current.component(.day, from: day.date))")
                        .font(.pretendardRegular(12))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 28)
    }
}

// MARK: - 월간 뷰
struct MonthChartView: View {
    let weekly: [WeeklySleep]

    // 축에 표시할 시간 라벨 (상단부터 순서대로)
    private let timeLabels = ["21:00", "01:00", "05:00", "09:00", "13:00", "17:00", "21:00"]
    // 최대 시간: 24시간으로 잡으면 전체 높이를 풀 스케일로 사용
    private let maxHours: Double = 24

    var body: some View {
        GeometryReader { geo in
            let chartHeight = geo.size.height
            let chartWidth  = geo.size.width
            // 수평 그리드 라인을 몇 개로 나눌지
            let lineCount = timeLabels.count

            ZStack(alignment: .bottomLeading) {
                // 1) 그리드(dashed)
                Path { path in
                    for i in 0..<lineCount {
                        let y = chartHeight * CGFloat(i) / CGFloat(lineCount - 1)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: chartWidth, y: y))
                    }
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5,5]))
                .foregroundColor(Color.gray06.opacity(0.2))

                // 2) 막대 그래프
                HStack(alignment: .bottom, spacing: 24) {
                    ForEach(weekly, id: \.week) { week in
                        VStack(spacing: 4) {
                            if let h = week.hours, let m = week.minutes {
                                let total = Double(h) + Double(m)/60
                                Capsule()
                                    .fill(Color.green04)
                                    .frame(width: 20,
                                           height: CGFloat((total / maxHours) * chartHeight))
                            } else {
                                // 데이터 없을 때 얇은 회색 선
                                Capsule()
                                    .fill(Color.gray06.opacity(0.2))
                                    .frame(width: 20, height: 4)
                            }
                            Text(week.week)
                                .font(.pretendardRegular(12))
                                .foregroundColor(.gray06)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.leading, 40)  // 왼쪽 축 라벨 공간 확보

                // 3) 왼쪽 축 라벨
                VStack(spacing: 0) {
                    ForEach(timeLabels.indices, id: \.self) { i in
                        Text(timeLabels[i])
                            .font(.pretendardRegular(12))
                            .foregroundColor(.gray06)
                            .frame(height: chartHeight / CGFloat(lineCount - 1),
                                   alignment: .top)
                    }
                }
            }
            .padding(.horizontal, 28)
        }
        .frame(height: 200)  // 필요에 따라 조절
    }
}


// MARK: - Preview
struct SleepStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SleepStatsViewModel()
        return SleepStatsView(viewModel: viewModel)
    }
}

