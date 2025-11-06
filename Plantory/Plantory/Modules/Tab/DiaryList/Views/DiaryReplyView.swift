//
//  DiaryReplyView.swift
//  Plantory
//
//  Created by 주민영 on 11/5/25.
//

import SwiftUI

struct DiaryReplyView: View {
    @EnvironmentObject var vm: DiaryCheckViewModel
    
    var body: some View {
        VStack {
            if vm.state == nil {
                EmptyView()
            } else if vm.state == .loading {
                LoadingCardView()
            } else if vm.state == .arrived {
                ArrivedCardView(onConfirm: {
                    vm.state = .complete
                    vm.saveAsOpened()
                })
            } else if vm.state == .complete {
                CompleteCardView(vm: vm)
            }
        }
        .padding(.horizontal, 18)
    }
}

// MARK: - 모달 뷰

/// AI 답장 로딩 중
private struct LoadingCardView: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 12) {
            LoadingDotsView()
                .padding(.bottom, 10)
    
            Text("AI가 답장을 생성하고 있습니다.")
                .font(.pretendardSemiBold(18))
                .foregroundStyle(.black01Dynamic)
            
            Text("잠시만 기다려주세요.")
                .font(.pretendardRegular(14))
                .foregroundStyle(.gray09Dynamic)
        }
        .onAppear { animate = true }
        .frame(maxWidth: .infinity)
        .frame(height: 176)
        .background(Color.white01Dynamic)
        .cornerRadius(10)
    }
}

/// AI 답장 도착
private struct ArrivedCardView: View {
    var onConfirm: () -> Void   // 버튼 액션을 외부에서 주입
    
    var body: some View {
        VStack(spacing: 12) {
            // 아이콘
            Image("envelope_closed")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.green06Dynamic)
                .scaledToFit()
                .frame(width: 35, height: 48)
            
            // 텍스트
            Text("AI의 답장이 도착했습니다.")
                .font(.pretendardBold(18))
                .foregroundStyle(.black01Dynamic)

            // 버튼
            Button {
                onConfirm() //버튼 클릭
            } label: {
                Text("답장 확인하기")
                    .font(.pretendardRegular(14))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(.green06Dynamic)
                    .foregroundStyle(.white)
                    .cornerRadius(5)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 176)
        .background(Color.white01Dynamic)
        .cornerRadius(10)
    }
}

/// AI답장 확인
private struct CompleteCardView: View {
    @ObservedObject var vm: DiaryCheckViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image("envelope_open")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.green06Dynamic)
                .scaledToFit()
                .frame(width: 35, height: 48)
            
            // 상단 아이콘 + 제목
            HStack(spacing: 0) {
                Text("\(vm.nickname)")
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(.green06Dynamic)
                Text("님에게 드리는 답장")
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(.black01Dynamic)
            }

            // 본문
            Text(vm.summary?.aiComment ?? "답장 없음")
                .font(.pretendardRegular(16))
                .foregroundStyle(.gray11Dynamic)
                .multilineTextAlignment(.leading)
                .padding(12)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(height: 176)
        .background(Color.white01Dynamic)
        .cornerRadius(10)
    }
}

/// LoadingCardView의 컴포넌트
private struct LoadingDotsView: View {
    @State private var animate = false
    let totalDots = 6
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalDots, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "7B9349"))
                    .frame(width: 14, height: 14)
                    .offset(y: (i == 4 && animate) ? -8 : 0) // 5번째 원만 위로 점프
                    .opacity(animate ? 1.0 : 0.3)
                    .offset(y: animate ? -10 : 0) // 위로 솟아오르기
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(i) * 0.15), // 점차적으로 딜레이
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    DiaryReplyView()
        .environmentObject(DiaryCheckViewModel(diaryId: 1, container: DIContainer()))
}
