//
//  MyProgressView.swift
//  Plantory
//
//  Created by 김지우 on 8/6/25.
//


import SwiftUI

struct MyProgressView: View {
    @Bindable var viewModel: HomeViewModel

    private let cardSize = CGSize(width: 358, height: 105)
    private let percentLabelWidth: CGFloat = 36 // "100%" 폭 여유

    private var progress: CGFloat {
        let clamped = min(max(viewModel.wateringProgress, 0), 100)
        return CGFloat(clamped) / 100.0
    }
    private var currentStreak: Int { viewModel.continuousRecordCnt }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 8) // 상단 여백
            HStack(alignment: .center, spacing: 0) {
                Spacer().frame(width: 16) // 좌측 여백

                // 좌측: 제목 + 프로그레스
                VStack(alignment: .leading, spacing: 3) {
                    Text("나의 플랜토리")
                        .font(.pretendardRegular(14))
                        .foregroundStyle(.black01Dynamic)
                    progressbar
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 가운데 분리선
                Spacer().frame(width: 24)
                Divider()
                    .frame(width: 0.5, height: 88)
                    .background(.gray10Dynamic)
                Spacer().frame(width: 24)

                // 우측: 연속 기록
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(.clover)
                        HStack(spacing: 0.1) {
                            Text("\(currentStreak)")
                                .font(.pretendardBold(18))
                                .foregroundColor(.black01Dynamic)
                            Text("일")
                                .font(.pretendardRegular(14))
                                .foregroundColor(.black01Dynamic)
                        }
                    }
                    Text("현재 연속 기록")
                        .font(.pretendardRegular(10))
                        .foregroundColor(.mono04)
                }
                .offset(x: -8) 
                Spacer().frame(width: 16) // 우측 여백
            }
            Spacer().frame(height: 8) // 하단 여백
        }
        .frame(width: cardSize.width, height: cardSize.height, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.calendarbackground)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("나의 플랜토리 진행도 \(Int(progress * 100))퍼센트, 연속 기록 \(currentStreak)일")
            .font(.pretendardRegular(10)))
    }

    private var progressbar: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 상단 라벨
            HStack {
                VStack(spacing: 2) {
                    Text("새싹")
                        .font(.pretendardRegular(10))
                        .foregroundStyle(.homeIcon)
                    Circle().fill(.homeIcon).frame(width: 3, height: 3)
                }
                Spacer().frame(width: 68)
                VStack(spacing: 2) {
                    Text("잎새")
                        .font(.pretendardRegular(10))
                        .foregroundStyle(.homeIcon)
                    Circle().fill(.homeIcon).frame(width: 3, height: 3)
                }
            }

            // Progress 바
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.brown01Dynamic)
                    .frame(width: 187, height: 4)

                Capsule()
                    .fill(Color.progressbar)
                    .frame(width: 187 * progress, height: 4)
                    .animation(.easeInOut(duration: 0.25), value: progress)

                HStack {
                    Spacer().frame(width: 180)
                    Circle()
                        .fill(Color.brown01Dynamic)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("꽃나무")
                                .font(.pretendardRegular(10))
                                .foregroundColor(.black01Dynamic)
                        )
                }
                .frame(width: 230, height: 10)
            }

            // 퍼센트 레이블
            Spacer().frame(height: 5) // progress 바와 5 간격
            ZStack(alignment: .leading) {
                Color.clear.frame(width: 187, height: 0)
                let targetX = 187 * progress - percentLabelWidth / 2
                let clampedX = max(0, min(187 - percentLabelWidth, targetX))
                Text("\(Int(progress * 100))%")
                    .font(.pretendardRegular(10))
                    .foregroundStyle(.homeIcon)
                    .frame(width: percentLabelWidth, alignment: .center)
                    .offset(x: clampedX)
                    .animation(.easeInOut(duration: 0.25), value: progress)
            }
        }
    }
}
