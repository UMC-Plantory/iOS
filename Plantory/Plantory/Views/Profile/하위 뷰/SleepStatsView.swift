import SwiftUI

struct SleepStatsView: View {
    @StateObject private var viewModel: SleepStatsViewModel
    @State private var page = 0

    init(response: WeeklySleepResponse) {
        _viewModel = StateObject(wrappedValue: SleepStatsViewModel(response: response))
    }

    var body: some View {
        VStack(spacing: 24) {
            WeekMonthPicker(selection: $page)
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.periodText)
                    .font(.pretendardRegular(14))
                    .foregroundColor(.gray06)
                Text(viewModel.averageText)
                    .font(.pretendardSemiBold(32))
            }
            .padding(.horizontal, 28)
            if page == 0 {
                WeekChartView(daily: viewModel.daily)
            } else {
                MonthChartView(daily: viewModel.daily)
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
    let daily: [DailySleep]

    var body: some View {
        Text("월간 차트 구현 자리")
            .font(.pretendardRegular(16))
            .foregroundColor(.gray06)
    }
}

// MARK: - Preview

struct SleepStatsView_Previews: PreviewProvider {
    static var previews: some View {
        // 1) 샘플 JSON 디코더 (필요 시 .iso8601 → .formatted(DateFormatter())로 바꿔주세요)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // 2) 디코딩 시도 & 실패 시 빈 AverageEntry 로 대체
        let response: WeeklySleepResponse = {
            do {
                return try decoder.decode(
                    WeeklySleepResponse.self,
                    from: SleepAPI.weeklyStats.sampleData
                )
            } catch {
                return WeeklySleepResponse(
                    startDate: Date(),
                    endDate:   Date(),
                    daily:     [],
                    average:   .init(hours: 0, minutes: 0)  // ← 여기를 수정
                )
            }
        }()

        return SleepStatsView(response: response)
    }
}
