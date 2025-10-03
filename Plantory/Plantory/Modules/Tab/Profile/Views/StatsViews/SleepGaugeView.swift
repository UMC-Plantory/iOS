//
//  SleepGaugeView.swift
//  Plantory
//
//  Created by 이효주 on 7/22/25.
//

import SwiftUI

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
                    .fill(Color.clear)
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
                    .foregroundColor(.green06Dynamic)
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

#Preview {
    SleepGaugeView(progress: 0.4, label: "7H 8M")
        .frame(width: 120, height: 120)
}
