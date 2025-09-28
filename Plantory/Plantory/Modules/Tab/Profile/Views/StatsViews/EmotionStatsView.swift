//
//  EmotionStatsView.swift
//  Plantory
//
//  Created by 이효주 on 7/8/25.
//

import SwiftUI
import Charts

struct EmotionStatsView: View {
    @StateObject private var viewModel: EmotionStatsViewModel
    @State private var page: Int = 0    // 0 = Week, 1 = Month

    init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: EmotionStatsViewModel(container: container))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer().frame(height: 45)
            
            WeekMonthPicker(selection: $page)
                .frame(maxWidth: .infinity, alignment: .center)
                .onChange(of: page) { old, new in
                    if new == 0 { viewModel.fetchWeeklyEmotionStats()
                    }
                    else {
                        // 월간 감정 통계 패치 함수
                    }
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.comment)
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(.black01Dynamic)
                Text(viewModel.periodText)
                    .font(.pretendardRegular(16))
                    .foregroundColor(.gray09Dynamic)
                HStack {
                    (
                        Text("오늘은 \(viewModel.todayWeekdayLabel)이에요!\n지난 한 주간에는 ")
                        + Text(viewModel.mostFrequentEmotionLabel).bold()
                        + Text("이 가장 많이 기록 되었어요!")
                    )
                    .font(.pretendardRegular(12))
                    .foregroundColor(.green06Dynamic)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 50, alignment: .topLeading)
                    Spacer()
                }
                HStack{
                    Spacer()
                    if viewModel.topEmotionKey != "" {
                        EmotionGaugeView(
                            progress: viewModel.topEmotionRatio,
                            emotionKey: viewModel.topEmotionKey
                        )
                        .frame(width: 120, height: 120)
                    }
                }
                Spacer().frame(height: 30)
                EmotionPercentageChartView(data: viewModel.emotionPercentages)
            }
            Spacer()
        }
        .padding(.horizontal, 28)
        .onChange(of: page) { _, new in
            if new == 0 {
                viewModel.fetchWeeklyEmotionStats()
            } else {
                viewModel.fetchMonthlyEmotionStats()
            }
        }
        .loadingIndicator(viewModel.isLoading)
    }
}

/// 감정별 점유율을 막대 그래프로 표시하는 차트 뷰
struct EmotionPercentageChartView: View {
    /// 차트에 표시할 데이터: 한글 레이블, 퍼센트
    let data: [EmotionStatsViewModel.EmotionPercentage]

    /// 감정별 그라데이션 색상 매핑 (한글 레이블 기준)
    private let gradientColorMap: [String: [Color]] = [
        "기쁨":     [Color.happy.opacity(0.1), Color.happy.opacity(0.3), Color.happy.opacity(0.8)],
        "놀람":     [Color.surprised.opacity(0.1),  Color.surprised.opacity(0.3),  Color.surprised.opacity(0.8)],
        "슬픔":     [Color.sad.opacity(0.1),   Color.sad.opacity(0.3),   Color.sad.opacity(0.8)],
        "화남":     [Color.mad.opacity(0.1),   Color.mad.opacity(0.3),   Color.mad.opacity(0.8)],
        "그저그럼": [Color.soso.opacity(0.1),   Color.soso.opacity(0.3), Color.soso.opacity(0.8)]
    ]

    var body: some View {
        Chart(data) { item in
            let colors = gradientColorMap[item.emotion] ?? [Color.gray.opacity(0.1), Color.gray.opacity(0.2), Color.gray.opacity(0.3)]
            BarMark(
                x: .value("감정", item.emotion),
                y: .value("점유율", item.percentage),
                width: .fixed(20)
            )
            .cornerRadius(50)
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: colors[0], location: 0),
                        .init(color: colors[1], location: 0.3),
                        .init(color: colors[2], location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading, values: Array(stride(from: 0, through: 100, by: 20))) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5,5]))
                    .foregroundStyle(Color.gray09)
                if let intValue = value.as(Int.self) {
                    AxisValueLabel {
                        Text("\(intValue)%")
                            .font(.pretendardRegular(12))
                            .foregroundStyle(Color.gray09Dynamic)
                            .padding(.leading, 8)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: data.map { $0.emotion }) { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .font(.pretendardRegular(12))
                            .foregroundStyle(Color.gray09Dynamic)
                    }
                }
            }
        }
        .frame(height: 300)
    }
}

#Preview {
    EmotionStatsView(container: .init())
}
