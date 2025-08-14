//
//  MyGardenView.swift
//  Plantory
//
//  Created by 박정환 on 7/15/25.
//

import SwiftUI

struct MyGardenContent: View {
    @State private var viewModel = TerrariumViewModel(container: DIContainer()) // @State로 수정
    @State private var selectedSegment: String = "나의 정원"
    @State private var isPlantPopupPresented: Bool = false
    @State private var popupVM = PlantPopupViewModel(container: DIContainer())
    var onPlantTap: (Int) -> Void

    var body: some View {
        VStack {
            TopView(viewModel: viewModel)
                .padding(.bottom, 36)

            // 데이터를 제대로 받아왔을 때, PlantListView 표시
            if !viewModel.monthlyTerrariums.isEmpty {
                PlantListView(items: viewModel.monthlyTerrariums, onPlantTap: onPlantTap)
            }

            Spacer()
        }
        .onAppear {
            viewModel.fetchMonthlyTerrarium()
        }
    }
}

struct TopView: View {
    @State var viewModel: TerrariumViewModel  // @State로 뷰모델 사용

    var body: some View {
        HStack {
            (
                Text(viewModel.monthlyTerrariums.first?.nickname ?? "")
                    .font(.pretendardSemiBold(20)) +
                Text(" 님의 식물").font(.pretendardRegular(20))
            )

            Spacer()

            HStack(spacing: 8) {
                Button {
                    viewModel.goToPreviousMonth()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }

                Text(Self.monthLabel(from: viewModel.selectedMonth))
                    .font(.headline)

                Button {
                    viewModel.goToNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 55)
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

    var items: [TerrariumMonthly] = []
    var onPlantTap: (Int) -> Void

    var body: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items, id: \.terrariumId) { item in
                    Button {
                        onPlantTap(item.terrariumId)
                    } label: {
                        VStack(spacing: 8) {
                            Image("Rose")
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
}

#Preview {
    MyGardenContent(onPlantTap: { _ in })
}
