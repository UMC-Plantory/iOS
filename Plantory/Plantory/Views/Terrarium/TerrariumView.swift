//
//  TerrariumView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct TerrariumView: View {
    @EnvironmentObject var container: DIContainer
    @State var viewModel: TerrariumViewModel
    @State private var selectedPlantIndex: Int? = nil
    @State private var isPlantPopupPresented: Bool = false
    @State private var popupVM = PlantPopupViewModel(container: DIContainer())
    @Binding var showFlowerCompleteView: Bool
    var onInfoTapped: () -> Void
    var memberId: Int = 1

    init(viewModel: TerrariumViewModel, onInfoTapped: @escaping () -> Void, showFlowerCompleteView: Binding<Bool>) {
        self.viewModel = viewModel
        self.onInfoTapped = onInfoTapped
        self._showFlowerCompleteView = showFlowerCompleteView  // 초기화 시 Binding 값 전달
    }

    var body: some View {
        ZStack {
            Color("yellow01")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                CustomSegmentView(selectedSegment: $viewModel.selectedTab)

                if viewModel.selectedTab == .terrarium {
                    GeometryReader { geometry in
                        VStack {
                            HStack {
                                SpeechBubble(message: Text(viewModel.wateringMessage)) // Text로 감싸서 전달
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 39)
                            .padding(.trailing, 16)
                            .padding(.bottom,10)

                            ProgressGaugeView(currentStage: viewModel.terrariumData?.terrariumWateringCount ?? 0)

                            Spacer()

                            Image(viewModel.terrariumData?.terrariumWateringCount ?? 0 < 3 ? "sprout" : "leaf")
                                .resizable()
                                .frame(width: 286, height: 286)

                            Spacer()

                            WateringButton(
                                count: viewModel.terrariumData?.memberWateringCount ?? 0,
                                action: {
                                    viewModel.waterPlant()
                                    checkForFlowerComplete()  // 물주기 후 상태 확인
                                }
                            )

                            Spacer()

                            HStack {
                                Button(action: {
                                    onInfoTapped()
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
                    MyGardenContent(onPlantTap: { id in
                        selectedPlantIndex = id
                        isPlantPopupPresented = true
                        popupVM.open(terrariumId: id, name: "식물 \(id)")
                    })
                }
            }

            if let index = selectedPlantIndex, isPlantPopupPresented {
                PlantPopupView(
                    viewModel: popupVM,
                    onClose: {
                        isPlantPopupPresented = false
                        selectedPlantIndex = nil
                        popupVM.close()
                    }
                )
                .zIndex(1)
            }
        }
        .onAppear {
            viewModel.fetchTerrarium() // 로그인한 아이디
            checkForFlowerComplete()  // 처음 로드될 때 상태 확인
        }
    }

    // terrariumWateringCount가 7이면 FlowerCompleteView 표시
    func checkForFlowerComplete() {
        if let wateringCount = viewModel.terrariumData?.terrariumWateringCount, wateringCount >= 7 {
            showFlowerCompleteView = true  // 상태 변경
        }
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
                            .stroke(Color("green06"), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
    }
}

struct TerrariumView_Preview: PreviewProvider {
    @State static private var showFlowerCompleteView = false  // Define the @State here

    static var previews: some View {
        TerrariumView(
            viewModel: TerrariumViewModel(container: DIContainer()),
            onInfoTapped: { print("Info tapped") },
            showFlowerCompleteView: $showFlowerCompleteView  // Pass the binding
        )
    }
}
