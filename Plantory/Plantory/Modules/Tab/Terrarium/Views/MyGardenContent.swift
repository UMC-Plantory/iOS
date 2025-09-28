//
//  MyGardenView.swift
//  Plantory
//
//  Created by 박정환 on 7/15/25.
//

import SwiftUI

struct MyGardenContent: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var popupManager: PopupManager
    
    @State private var viewModel: TerrariumViewModel
    @State private var selectedSegment: String = "나의 정원"
    @State private var popupVM: PlantPopupViewModel
    
    init(container: DIContainer) {
        self.viewModel = TerrariumViewModel(container: container)
        self.popupVM = PlantPopupViewModel(container: container)
    }

    var body: some View {
        VStack {
            TopView(viewModel: viewModel)
                .padding(.bottom, 36)

            // 데이터를 제대로 받아왔을 때, PlantListView 표시
            if !viewModel.monthlyTerrariums.isEmpty {
                PlantListView(items: viewModel.monthlyTerrariums, onPlantTap: { id in
                    container.selectedTab = .terrarium
                    viewModel.selectedTab = .myGarden
                    popupVM.open(terrariumId: id)
                    popupManager.show {
                        PlantPopupView(
                            viewModel: popupVM,
                            onClose: {
                                viewModel.selectedTab = .myGarden
                                popupManager.dismiss()
                                popupVM.close()
                            }
                        )
                        .environmentObject(container)
                    }
                })
            }

            Spacer()
        }
        .onAppear {
            viewModel.fetchMonthlyTerrarium()
        }
    }
}

struct TopView: View {
    @State private var viewModel: TerrariumViewModel
    @State private var fixedNickname: String? = nil

    init(viewModel: TerrariumViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        HStack {
            (
                Text((fixedNickname ?? viewModel.monthlyNickname) ?? "")
                    .font(.pretendardSemiBold(20)) +
                Text(" 님의 식물").font(.pretendardRegular(20))
            )

            Spacer()

            HStack(spacing: 8) {
                Button {
                    viewModel.goToPreviousMonth()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black01Dynamic)
                }

                Text(Self.monthLabel(from: viewModel.selectedMonth))
                    .foregroundStyle(.black01Dynamic)
                    .font(.headline)

                Button {
                    viewModel.goToNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.black01Dynamic)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 55)
        .onAppear {
            if fixedNickname == nil {
                fixedNickname = viewModel.monthlyNickname
            }
        }
        .onChange(of: viewModel.monthlyTerrariums.count) { _, _ in
            if fixedNickname == nil {
                fixedNickname = viewModel.monthlyNickname
            }
        }
    }

    private static func monthLabel(from date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월"
        return f.string(from: date)
    }
}

struct PlantListView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    let items: [TerrariumMonthlyListItem]
    var onPlantTap: (Int) -> Void

    var body: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items, id: \.terrariumId) { item in
                    Button {
                        onPlantTap(item.terrariumId)
                    } label: {
                        VStack(spacing: 8) {
                            Image(imageName(for: item.flowerName))
                                .resizable()
                                .frame(width: 70, height: 70)

                            HStack(spacing: 4) {
                                Text(item.flowerName)
                                    .font(.pretendardSemiBold(14))
                                    .foregroundColor(.black)

                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 8, height: 12)
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(width: 114, height: 114)
                        .background(Color("brown01"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color("brown03"), lineWidth: 1)
                        )
                        .cornerRadius(5)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func imageName(for koreanName: String) -> String {
        switch koreanName {
        case "장미": return "Rose"
        case "민들레": return "Dandelion"
        case "해바라기": return "Sunflower"
        case "개나리": return "Forsythia"
        case "물망초": return "ForgetMeNot"
        default: return "Rose" // 기본 이미지
        }
    }
}

#Preview {
    MyGardenContent(container: DIContainer())
}
