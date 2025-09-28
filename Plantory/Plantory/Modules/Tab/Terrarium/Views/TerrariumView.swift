//
//  TerrariumView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct TerrariumView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var popupManager: PopupManager
    
    @State var viewModel: TerrariumViewModel
    @State private var showFlowerComplete: Bool = false

    init(container: DIContainer) {
        self.viewModel = TerrariumViewModel(container: container)
    }

    var body: some View {
        ZStack {
            Color.terrariumbackground.ignoresSafeArea()

            VStack(spacing: 0) {
                CustomSegmentView(selectedSegment: $viewModel.selectedTab)

                if viewModel.selectedTab == .terrarium {
                    GeometryReader { geometry in
                        VStack {
                            HStack {
                                SpeechBubble(message: Text(viewModel.wateringMessage))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 39)
                            .padding(.trailing, 16)
                            .padding(.bottom,10)

                            ProgressGaugeView(currentStage: viewModel.terrariumData?.terrariumWateringCount ?? 0)

                            Spacer()

                            Image(viewModel.terrariumData?.terrariumWateringCount ?? 0 < 3 ? "Sprout" : "Leaf")
                                .resizable()
                                .frame(width: 286, height: 286)

                            Spacer()

                            WateringButton(
                                count: viewModel.terrariumData?.memberWateringCount ?? 0,
                                action: {
                                    viewModel.waterPlant()
                                }
                            )

                            Spacer()

                            HStack {
                                Button(action: {
                                    popupManager.show {
                                        TerrariumPopup()
                                            .environmentObject(popupManager)
                                    }
                                }) {
                                    Image("information")
                                }
                                Spacer()
                            }
                            .padding(.bottom, 96).padding(.leading, 16)
                        }
                        .background(
                            Ellipse()
                                .fill(Color("green04"))
                                .frame(width: 631, height: 363)
                                .offset(y: 60),
                            alignment: .bottom
                        )
                    }
                } else {
                    MyGardenContent(container: container)
                    .environmentObject(container)
                    .environmentObject(popupManager)
                }
            }
        }
        .onChange(of: viewModel.terrariumData?.terrariumWateringCount) { _, newValue in
            if let c = newValue, c >= 7 {
                showFlowerComplete = true // 부모에게 “띄워!” 신호
            }
        }
        .onAppear {
            viewModel.fetchTerrarium()
            if let c = viewModel.terrariumData?.terrariumWateringCount, c >= 7 {
                showFlowerComplete = true // 진입 시 이미 7 이상이면 즉시 요청
            }
        }
        .fullScreenCover(isPresented: $showFlowerComplete, onDismiss: {
            viewModel.fetchTerrarium()
        }) {
            FlowerCompleteView(
                viewModel: viewModel,
                onGoToGarden: {
                    container.selectedTab = .terrarium
                    viewModel.selectedTab = .myGarden
                    showFlowerComplete = false
                },
                onGoHome: {
                    container.selectedTab = .home
                    showFlowerComplete = false
                }
            )
            .environmentObject(container)
            .onAppear {
                // FlowerCompleteView가 나타날 때 갱신
                viewModel.fetchTerrarium()
            }
        }
        .loadingIndicator(viewModel.isLoading)
    }
}

//말풍선
struct SpeechBubble: View {
    var message: Text

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            message
                .font(.pretendardRegular(16))
                .foregroundColor(.black)
                .padding(11)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color("green06"), lineWidth: 1)
                        .background(Color.white.cornerRadius(10))
                )
            Triangle()
                .fill(Color.white)
                .overlay(
                    Triangle().stroke(Color("green06"), lineWidth: 1)
                )
                .frame(width: 16, height: 14)
                .rotationEffect(.degrees(180))
                .offset(x: 140)
        }
    }
}

//말풍선 아래 붙일 삼각형
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // top center
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // bottom right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom left
        path.closeSubpath()
        return path
    }
}

//물주기
struct WateringButton: View {
    var count: Int
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 8) {
                Image("Watering")
                Text("\(count)")
                    .font(.pretendardRegular(28))
                    .foregroundColor(.black)
            }
            .frame(width: 105, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color("green06Always"), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    TerrariumView(container: DIContainer())
}
