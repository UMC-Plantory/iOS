//
//  ProgressGaugeView.swift
//  Plantory
//
//  Created by 박정환 on 7/17/25.
//

import SwiftUI

struct ProgressGaugeView: View {
    let currentStage: Int  // 0부터 시작해서 최대 7까지

    let stepWidth: CGFloat = 44
    let stepSpacing: CGFloat = 3
    let totalSteps = 7
    
    var body: some View {
        let colors = labelColors()
        return ZStack {
            // 게이지 배경
            Image("gauge_track")
                .resizable()
                .frame(width: 333, height: 74)

            // 초록색 진행도 상자
            HStack(spacing: stepSpacing) {
                ForEach(0..<6, id: \.self) { i in
                    if i < currentStage {
                        GradientBox(
                            width: stepWidth,
                            height: 21,
                            LightGradient: i < 3,
                            isCircle: false
                        )
                    } else {
                        GradientBox(width: stepWidth, height: 21, isCircle: false, noGradient: true)
                            .cornerRadius(5)
                    }
                }
            }
            .frame(width: 333, height: 74, alignment: .leading)
            .padding(.leading, 13)
            .padding(.top, 10)

            // 원형 배경(항상 표시) — 트랙의 왼쪽에서 276, 아래에서 4 만큼 오프셋
            Image("gauge_circle_bg")
                .resizable()
                .frame(width: 68, height: 65)
                .frame(width: 333, height: 74, alignment: .bottomLeading)
                .offset(x: 269, y: 0)
                .zIndex(1)

            // 원형 내용: 7이 아닐 때도 항상 noGradient로 표시, 7일 때만 그라디언트
            GradientBox(width: 51, isCircle: true, noGradient: currentStage != 7)
                .frame(width: 51, height: 51)
                .frame(width: 333, height: 74, alignment: .bottomLeading)
                .offset(x: 279, y: -7)
                .zIndex(2)

            // 단계 라벨 (위쪽)
            Text("새싹")
                .font(.pretendardSemiBold(14))
                .foregroundColor(colors.sprout)
                .position(x: stepXPosition(index: 0), y: 12)
            Text("잎새")
                .font(.pretendardSemiBold(14))
                .foregroundColor(colors.leaf)
                .position(x: stepXPosition(index: 3) - 4, y: 12)
            Text("꽃나무")
                .font(.pretendardSemiBold(14))
                .foregroundColor(colors.flower)
                .position(x: stepXPosition(index: 6) + 12, y: 46) // 오른쪽 원형 마커 중앙에 위치
                .zIndex(3)
        }
        .frame(width: 333, height: 74)
    }

    // 각 단계의 X좌표 계산
    func stepXPosition(index: Int) -> CGFloat {
        let startX: CGFloat = stepWidth / 2 - 5
        return startX + CGFloat(index) * (stepWidth + stepSpacing)
    }

    // Helper: dynamic label colors
    private func labelColors() -> (sprout: Color, leaf: Color, flower: Color) {
        let green = Color("green06")
        let brown = Color("brown03")

        if currentStage <= 3 { // 3 이하면: 새싹 green, 나머지 brown
            return (green, brown, brown)
        } else if currentStage < 7 { // 3 이상 ~ 6: 새싹, 잎새 green / 꽃나무 brown
            return (green, green, brown)
        } else { // 7: 모두 green
            return (green, green, green)
        }
    }
}

#Preview {
    ProgressGaugeView(currentStage: 7)
}
