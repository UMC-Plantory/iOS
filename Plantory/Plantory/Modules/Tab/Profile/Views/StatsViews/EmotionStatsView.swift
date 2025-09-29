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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Spacer().frame(height: 45)

                WeekMonthPicker(selection: $page)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onChange(of: page) { _, new in
                        if new == 0 {
                            viewModel.fetchWeeklyEmotionStats()
                        } else {
                            viewModel.fetchMonthlyEmotionStats()
                        }
                    }

                // 주간/월간 영역 전환
                Group {
                    if page == 0 {
                        weeklyArea
                    } else {
                        monthlyArea
                    }
                }
            }
            .padding(.horizontal, 28)
            .loadingIndicator(viewModel.isLoading)
        }
        .onAppear {
            // 최초 진입 시 주간 패치
            viewModel.fetchWeeklyEmotionStats()
        }
    }
}

// MARK: - Weekly / Monthly Content
private extension EmotionStatsView {

    @ViewBuilder
    var weeklyArea: some View {
        if !viewModel.weeklyLoaded {
            loadingView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.isWeeklyEmpty {
            VStack {
                Spacer().frame(height: 120)
                    NothingView(
                        mainText: "주간 감정 통계 기록이 없어요",
                        subText: "하루 하루 일기를 통해 감정을 기록해 보세요!"
                    )
                    Spacer()
                }
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.isMonthlyEmpty {
            VStack {
                Spacer().frame(height: 120)
                NothingView(
                    mainText: "월간 감정 통계 기록이 없어요",
                    subText: "한 달 동안의 감정 패턴을 모아볼 수 있어요!"
                )
                Spacer()
            }
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
            EmotionPercentageChartView(data: viewModel.emotionPercentages)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var monthlyContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            EmotionPercentageChartView(data: viewModel.emotionPercentages)
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
                (
                    Text("오늘은 \(viewModel.todayWeekdayLabel)이에요!\n지난 기간에는 ")
                    + Text(viewModel.mostFrequentEmotionLabel).bold()
                    + Text("이 가장 많이 기록 되었어요!")
                )
                .font(.pretendardRegular(12))
                .foregroundColor(.green06)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 68, alignment: .topLeading)

                Spacer()

                if !viewModel.topEmotionKey.isEmpty {
                    EmotionGaugeView(
                        progress: viewModel.topEmotionRatio,
                        emotionKey: viewModel.topEmotionKey
                    )
                    .frame(width: 120, height: 120)
                }
            }
        }
    }
}

/// 감정별 점유율을 막대 그래프로 표시하는 차트 뷰
struct EmotionPercentageChartView: View {
    /// 차트에 표시할 데이터: 한글 레이블, 퍼센트
    let data: [EmotionStatsViewModel.EmotionPercentage]

    /// 감정별 그라데이션 색상 매핑 (한글 레이블 기준)
    private let gradientColorMap: [String: [Color]] = [
        "기쁨":     [Color.yellow.opacity(0.05), Color.yellow.opacity(0.1), Color.yellow.opacity(0.5)],
        "놀람":     [Color.green03.opacity(0.1),  Color.green03.opacity(0.4),  Color.green03.opacity(1.0)],
        "슬픔":     [Color.blue.opacity(0.05),   Color.blue.opacity(0.1),   Color.blue.opacity(0.3)],
        "화남":     [Color.pink.opacity(0.05),   Color.pink.opacity(0.1),   Color.pink.opacity(0.5)],
        "그저그럼": [Color.gray.opacity(0.05),   Color.gray.opacity(0.1),   Color.gray.opacity(0.5)]
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
                            .foregroundStyle(Color.gray09)
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
                            .foregroundStyle(Color.gray09)
                    }
                }
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Preview
#Preview {
    let container = DIContainer()
    EmotionStatsView(container: container)
}
