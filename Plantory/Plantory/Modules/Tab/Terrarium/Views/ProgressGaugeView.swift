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
        ZStack {
            // 게이지 배경
            Image("gauge_background")
                .resizable()
                .frame(width: 333, height: 74)

            // 초록색 진행도 상자
            HStack(spacing: stepSpacing) {
                ForEach(0..<totalSteps, id: \.self) { i in
                    if i == 6 && i < currentStage {
                        GradientBox(width: 51, isCircle: true)
                            .offset(x: -9, y: -1)
                    } else {
                        if i < currentStage {
                            GradientBox(
                                width: stepWidth,
                                height: 21,
                                LightGradient: i < 3,
                                isCircle: false
                            )
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: stepWidth, height: 21)
                                .cornerRadius(5)
                        }
                    }
                }
            }
            .frame(width: 333, height: 74, alignment: .leading)
            .padding(.leading, 13)
            .padding(.top, 10)

            // 단계 라벨 (위쪽)
            Text("새싹")
                .font(.pretendardSemiBold(14))
                .foregroundColor(Color("green06"))
                .position(x: stepXPosition(index: 0), y: 12)
            Text("잎새")
                .font(.pretendardSemiBold(14))
                .foregroundColor(Color("green06"))
                .position(x: stepXPosition(index: 3) - 2, y: 12)
            Text("꽃나무")
                .font(.pretendardSemiBold(14))
                .foregroundColor(Color("green06"))
                .position(x: stepXPosition(index: 6) + 13, y: 45) // 오른쪽 원형 마커 중앙에 위치
        }
        .frame(width: 333, height: 74)
    }

    // 각 단계의 X좌표 계산
    func stepXPosition(index: Int) -> CGFloat {
        let startX: CGFloat = stepWidth / 2 - 5
        return startX + CGFloat(index) * (stepWidth + stepSpacing)
    }
}


#Preview {
    ProgressGaugeView(currentStage: 7)
}
