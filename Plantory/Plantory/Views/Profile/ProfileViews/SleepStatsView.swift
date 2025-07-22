import SwiftUI
import Charts

struct SleepStatsView: View {
    @StateObject private var viewModel: SleepStatsViewModel
    @State private var page: Int = 0    // 0 = Week, 1 = Month

    init(viewModel: SleepStatsViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                Text(viewModel.periodText)
                    .font(.pretendardRegular(16))
                    .foregroundColor(.gray09)
                HStack {
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
    }
}



// MARK: - 페이징 탭
struct WeekMonthPicker: View {
    @Binding var selection: Int    // 0 = Week, 1 = Month
    private let titles = ["Week", "Month"]

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 25) {
                ForEach(0..<titles.count, id: \.self) { idx in
                    Button {
                        withAnimation { selection = idx }
                    } label: {
                        Text(titles[idx])
                            .font(.pretendardSemiBold(20))
                            .foregroundColor(selection == idx ? .black : .gray06)
                            .frame(maxWidth: 60)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            HStack(spacing: 0) {
                ForEach(0..<titles.count, id: \.self) { idx in
                    Rectangle()
                        .fill(selection == idx ? Color.black : Color.clear)
                        .frame(height: 1)
                        .frame(width: 84)
                }
            }
        }
    }
}

struct SleepGaugeView: View {
    /// 0.0 ~ 1.0
    let progress: Double
    /// 예: "7h 24m"
    let label: String

    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            let diameter = min(geo.size.width, geo.size.height)
            let lineWidth = diameter * (16 / 120)

            ZStack {
                // 1) 큰 흰색 원
                Circle()
                    .fill(Color.white)
                    .frame(width: diameter, height: diameter)

                // 2) 흰색 테두리 + 그림자
                Circle()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: lineWidth))
                    .frame(width: diameter, height: diameter)
                    .shadow(color: Color.black.opacity(0.1),
                            radius: lineWidth/5,
                            x: 0, y: lineWidth/4)

                // 3) 그라디언트 게이지
                Circle()
                    .trim(from: 0, to: CGFloat(animatedProgress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.green01, location: 0.0),
                                .init(color: Color.green02, location: 0.5),
                                .init(color: Color.green03, location: 1.0)
                            ]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(.degrees(-90))

                // 4) 중앙 텍스트
                Text(label)
                    .font(.pretendardSemiBold(diameter * 0.2))
                    .foregroundColor(.green06)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}


// MARK: - WeekChartView
struct WeekChartView: View {
    let daily: [DailySleep]
    
    // y축 도메인(21시부터 +24h) 및 눈금 설정
    private let axisMin: Double = 21
    private var domainLower: Double { axisMin }
    private var domainUpper: Double { axisMin + 24 }
    private var yTickValues: [Double] { [21, 25, 29, 33, 37, 41, 45] }
    private var yTickLabels: [String] {
        ["21:00", "01:00", "05:00", "09:00", "13:00", "17:00", "21:00"]
    }
    
    var body: some View {
        Chart {
            ForEach(daily) { record in
                BarMark(
                    x: .value("요일", record.weekday),
                    yStart: .value("취침", flipped(numericHour(from: record.startTime))),
                    yEnd:   .value("기상", flipped(numericHour(from: record.endTime))),
                    width:  .fixed(20)
                )
                .cornerRadius(50)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.green01, location: 0.0),
                            .init(color: Color.green02, location: 0.5),
                            .init(color: Color.green03, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        // y축 커스텀 눈금
        .chartYScale(domain: domainLower...domainUpper)
        .chartYAxis {
            AxisMarks(position: .leading, values: yTickValues) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5,5]))
                    .foregroundStyle(Color.gray09)
                if let v = value.as(Double.self),
                   let idx = Array(yTickValues.reversed()).firstIndex(of: v) {
                    AxisValueLabel(yTickLabels[idx])
                        .font(.pretendardRegular(12))
                        .foregroundStyle(.gray09)
                }
            }
        }
        // x축: 요일 아래에 날짜(“6/15”) 포함
        .chartXAxis {
            AxisMarks(values: daily.map(\.weekday)) { value in
                AxisValueLabel {
                    if let weekday = value.as(String.self),
                       let rec = daily.first(where: { $0.weekday == weekday }) {
                        VStack(spacing: 2) {
                            Text(weekday)
                            Text(rec.date, format: .dateTime
                                                        .month(.defaultDigits)
                                                        .day(.defaultDigits))
                        }
                        .font(.pretendardRegular(12))
                        .foregroundStyle(.gray09)
                    }
                }
            }
        }
        .frame(height: 300)
    }
    
    // Date → 연속값(시간) 변환: 21시 기준 넘어가면 +24h
    private func numericHour(from date: Date) -> Double {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        var h = Double(comps.hour ?? 0) + Double(comps.minute ?? 0) / 60
        if h < axisMin { h += 24 }
        return h
    }
    
    // y축 뒤집기를 위한 보정
    private func flipped(_ value: Double) -> Double {
        domainLower + domainUpper - value
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

