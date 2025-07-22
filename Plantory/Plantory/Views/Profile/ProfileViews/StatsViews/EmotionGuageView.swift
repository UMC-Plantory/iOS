import SwiftUI

/// 주간 감정 게이지 뷰
/// - progress: 0.0 ~ 1.0, 전체 감정 중 최다 감정 비율
/// - emotionKey: API에서 받은 영어 키 ("joy", "sadness" 등)
struct EmotionGaugeView: View {
    let progress: Double
    let emotionKey: String

    @State private var animatedProgress: Double = 0

    // 감정 키 → 이미지 자산 이름 매핑
    private static let imageNameMap: [String: String] = [
        "joy":      "happy",
        "surprise": "surprise",
        "sadness":  "sad",
        "anger":    "angry",
        "soso":     "soso"
    ]
    
    // 감정 키 → 게이지 그라데이션 색상 매핑
    private static let gradientColorMap: [String: [Color]] = [
        "joy":      [Color.yellow.opacity(0.01), Color.yellow.opacity(0.2), Color.yellow.opacity(0.3)],
        "surprise": [Color.green.opacity(0.01), Color.green.opacity(0.1), Color.green.opacity(0.2)],
        "sadness":  [Color.blue.opacity(0.01), Color.blue.opacity(0.1), Color.blue.opacity(0.2)],
        "anger":    [Color.pink.opacity(0.01), Color.pink.opacity(0.1), Color.pink.opacity(0.2)],
        "soso":     [Color.gray.opacity(0.01), Color.gray.opacity(0.1), Color.gray.opacity(0.2)]
    ]

    var body: some View {
        GeometryReader { geo in
            let diameter = min(geo.size.width, geo.size.height)
            let lineWidth = diameter * (16 / 120)
            let imageName = Self.imageNameMap[emotionKey] ?? "emotion_default"
            let colors = Self.gradientColorMap[emotionKey] ?? Self.gradientColorMap.values.first!

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

                // 3) 감정별 그라데이션 게이지
                Circle()
                    .trim(from: 0, to: CGFloat(animatedProgress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(stops: [
                                .init(color: colors[0], location: 0),
                                .init(color: colors[1], location: 0.5),
                                .init(color: colors[2], location: 1)
                            ]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(.degrees(-90))

                // 4) 중앙 이미지
                Image(imageName)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: diameter * 0.4, height: diameter * 0.4)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = max(0, min(progress, 1))
            }
        }
        .onChange(of: progress) { _, new in
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = max(0, min(new, 1))
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        EmotionGaugeView(progress: 0.6, emotionKey: "sadness")
            .frame(width: 120, height: 120)
        EmotionGaugeView(progress: 0.3, emotionKey: "joy")
            .frame(width: 120, height: 120)
    }
}
