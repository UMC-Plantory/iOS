//
//  CompletedView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

// 테라리움 탭으로 전환 신호
extension Notification.Name {
    static let switchToTerrariumTab = Notification.Name("SwitchToTerrariumTab")
}

struct CompletedView: View {
    @EnvironmentObject var container: DIContainer

    var body: some View {
        ZStack {
            Color.diarybackground.ignoresSafeArea()

            VStack(spacing: 20) {
                // 상단 홈 버튼
                HStack {
                    Spacer()
                    Button(
                        action: {
                            container.navigationRouter.reset()
                            container.navigationRouter.push(.baseTab)
                        }
                    ) {
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

                // 하단 버튼
                HStack {
                    Spacer()

                    MainMiddleButton(
                        text: "내 식물 보기",
                        isDisabled: false,
                        action: {
                            // 1) 베이스 탭으로 이동
                            container.navigationRouter.reset()
                            container.navigationRouter.push(.baseTab)
                            // 2) 테라리움 탭 전환 신호
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                NotificationCenter.default.post(name: .switchToTerrariumTab, object: nil)
                            }
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
            Image("only_sprout")
        }
    }
}
