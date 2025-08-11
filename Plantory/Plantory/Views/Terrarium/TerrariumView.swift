//
//  TerrariumView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct TerrariumView: View {
    @StateObject private var viewModel = TerrariumViewModel()
    @State private var selectedPlantIndex: Int? = nil
    @State private var isPlantPopupPresented: Bool = false

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
                                SpeechBubble(
                                    message: "<잎새>까지 \(7 - (viewModel.terrariumData?.memberWateringCount ?? 0))번 남았어요!"
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 39)
                            .padding(.trailing, 16)
                            .padding(.bottom,10)

                            ProgressGaugeView(currentStage: viewModel.terrariumData?.terrariumWateringCount ?? 0)
                            
                            Spacer()

                            // 서버에서 받은 flowerImgUrl 값이 존재할 경우 이미지를, 없으면 기본 Rose 이미지를 보여줌
                            if let urlString = viewModel.terrariumData?.flowerImgUrl,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .frame(width: 286, height: 286)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image("Rose")
                                    .resizable()
                                    .frame(width: 286, height: 286)
                            }

                            Spacer()
                            //물주기 버튼
                            WateringButton(
                                count: viewModel.terrariumData?.memberWateringCount ?? 0,
                                action: {
                                    viewModel.waterPlant(memberId: 1)
                                }
                            )
                            .padding(.bottom,151)
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
                    MyGardenContent(onPlantTap: { index in
                        selectedPlantIndex = index
                        isPlantPopupPresented = true
                    })
                }
            }
            
            if let index = selectedPlantIndex, isPlantPopupPresented {
                PlantPopupView(
                    viewModel: PlantPopupModel(
                        isPresented: true,
                        plantName: "장미 \(index + 1)",
                        feeling: "행복",
                        birthDate: "2024.04.21",
                        completeDate: "2024.05.21",
                        usedDates: ["04.21", "04.24", "04.28"],
                        stages: [("새싹", "04.21"), ("잎새", "05.05"), ("꽃나무", "05.15")]
                    ),
                    onClose: {
                        isPlantPopupPresented = false
                        selectedPlantIndex = nil
                    }
                )
                .zIndex(1)
            }
        }
        .onAppear {
            viewModel.fetchTerrarium(memberId: 1) //로그인한 아이디
        }
    }
}


//말풍선
struct SpeechBubble: View {
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(message)
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



#Preview {
    TerrariumView()
}
