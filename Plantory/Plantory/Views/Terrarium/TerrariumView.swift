//
//  TerrariumView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct TerrariumView: View {
    @State private var viewModel = TerrariumViewModel(container: DIContainer())
    @State private var selectedPlantIndex: Int? = nil
    @State private var isPlantPopupPresented: Bool = false
    @State private var popupVM = PlantPopupViewModel(container: DIContainer())
    var onInfoTapped: () -> Void = {}

    private var isRunningInPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        @Bindable var vm = viewModel
        ZStack {
            Color("yellow01")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                CustomSegmentView(selectedSegment: $vm.selectedTab)

#if DEBUG
                // DEBUG: 서버 응답 확인용 패널
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("DEBUG • Terrarium API")
                            .font(.system(size: 12, weight: .semibold))
                        if vm.isLoading {
                            ProgressView().scaleEffect(0.7)
                            Text("Loading...")
                                .font(.system(size: 12))
                        } else {
                            Text("Idle")
                                .font(.system(size: 12))
                        }
                        Spacer()
                        Button("Reload") {
                            vm.fetchTerrarium(memberId: 1)
                        }
                        .font(.system(size: 12, weight: .semibold))
                    }

                    if let err = vm.errorMessage, !err.isEmpty {
                        Text("Error: \(err)")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }

                    if let data = vm.terrariumData {
                        Text("terrariumId: \(data.terrariumId)")
                            .font(.system(size: 12))
                        Text("flowerImgUrl: \(data.flowerImgUrl)")
                            .font(.system(size: 12))
                            .lineLimit(1)
                        Text("terrariumWateringCount: \(data.terrariumWateringCount)")
                            .font(.system(size: 12))
                        Text("memberWateringCount: \(data.memberWateringCount)")
                            .font(.system(size: 12))
                    } else {
                        Text("(no data)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.06))
                .cornerRadius(8)
                .padding([.horizontal, .top], 12)
#endif

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
                            Spacer()
                            
                            //도움말 버튼
                            HStack {
                                Button(action: { onInfoTapped() }) {
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
            if !isRunningInPreviews {
                viewModel.fetchTerrarium(memberId: 1) // 로그인한 아이디
            }
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
    TerrariumView(onInfoTapped: {})
}
