//
//  MyGardenView.swift
//  Plantory
//
//  Created by 박정환 on 7/15/25.
//

import SwiftUI

struct MyGardenContent: View {
    @State private var selectedSegment: String = "나의 정원"
    @State private var viewModel = TerrariumViewModel(container: DIContainer())
    var onPlantTap: (Int) -> Void
    var memberId: Int = 1   // TODO: 실제 회원 ID로 교체

    var body: some View {
        @Bindable var vm = viewModel

        VStack {
            TopView(vm: vm, memberId: memberId)
                .padding(.bottom, 36)

            // 에러 표시 (선택)
            if let err = vm.errorMessage, !err.isEmpty {
                Text(err)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.bottom, 8)
            }

            PlantListView(items: vm.monthlyTerrariums, onPlantTap: onPlantTap)

            Spacer()
        }
        .onAppear {
            vm.fetchMonthlyTerrarium(memberId: memberId)
        }
    }
}

struct TopView: View {
    @Bindable var vm: TerrariumViewModel
    var memberId: Int

    var body: some View {
        HStack {
            (
                Text(vm.monthlyTerrariums.first?.nickname ?? "")
                    .font(.pretendardSemiBold(20)) +
                Text(" 님의 식물").font(.pretendardRegular(20))
            )

            Spacer()

            HStack(spacing: 8) {
                Button {
                    vm.goToPreviousMonth(memberId: memberId)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }

                Text(Self.monthLabel(from: vm.selectedMonth))
                    .font(.headline)

                Button {
                    vm.goToNextMonth(memberId: memberId)
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

// 식물 리스트
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
