import SwiftUI

struct CompletedView: View {
    @EnvironmentObject var container: DIContainer

    var body: some View {
        ZStack {
            Color.diarybackground.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        container.navigationRouter.push(.baseTab)
                    }) {
                        Image(.home)
                            .foregroundColor(.diaryfont)
                    }
                    Spacer().frame(width: 30)
                }

                Spacer().frame(height: 60)

                completedImage

                Spacer().frame(height: 20)

                Text("오늘의 감정이\n마음의 잎을 틔워냈어요")
                    .font(.pretendardBold(20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.diaryfont)

                Spacer().frame(height: 100)

                HStack {
                    Spacer()
                    MainMiddleButton(
                        text: "내 식물 보기",
                        isDisabled: false,
                        action: {
                            // TODO: 탭 전환
                        }
                    )
                    Spacer().frame(width: 28)
                }
            }
        }
    }

    private var completedImage: some View {
        ZStack {
            Image(.gradientCircle)
            Image(.brightsprout)
        }
    }
}

