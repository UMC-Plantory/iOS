//
//  EmotionStatsView.swift
//  Plantory
//
//  Created by 이효주 on 7/8/25.
//

import SwiftUI

struct EmotionStatsView: View {
    @StateObject private var viewModel: EmotionStatsViewModel
    @State private var page: Int = 0    // 0 = Week, 1 = Month

    init(viewModel: EmotionStatsViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                Text(viewModel.periodText)
                    .font(.pretendardRegular(16))
                    .foregroundColor(.gray09)
                HStack {
                    (
                        Text("오늘은 \(viewModel.todayWeekdayLabel)이에요!\n지난 한 주간에는 ")
                        + Text(viewModel.mostFrequentEmotionLabel).bold()
                        + Text("이 가장 많이 기록 되었어요!")
                    )
                    .font(.pretendardRegular(12))
                    .foregroundColor(.green06)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 68, alignment: .topLeading)
                    Spacer()
                }
                HStack{
                    Spacer()
                    EmotionGuageView()
                        .frame(width: 120, height: 120)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 28) 
    }
}

#Preview {
    EmotionStatsView()
}
