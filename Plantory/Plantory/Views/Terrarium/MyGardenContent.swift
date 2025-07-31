//
//  MyGardenView.swift
//  Plantory
//
//  Created by 박정환 on 7/15/25.
//

import SwiftUI

struct MyGardenContent: View {
    @State private var selectedSegment: String = "나의 정원"
    var onPlantTap: (Int) -> Void

    var body: some View {
        VStack {
            TopView(userName: "유엠씨")
                .padding(.bottom,36)
            
            PlantListView(onPlantTap: onPlantTap)
            
            Spacer()
        }
    }
}

struct TopView: View {
    var userName: String
    var body: some View {
        HStack {
            (
                Text(userName).font(.pretendardSemiBold(20)) +
                Text(" 님의 식물").font(.pretendardRegular(20))
            )

            Spacer()

            HStack(spacing: 8) {
                Button(action: {
                    // 이전 달
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }

                Text("6월")
                    .font(.headline)

                Button(action: {
                    // 다음 달
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top,55)
    }
}

//식물 리스트
struct PlantListView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var onPlantTap: (Int) -> Void

    var body: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<6) { index in
                    Button(action: {
                        onPlantTap(index)
                    }) {
                        VStack(spacing: 8) {
                            Image("Rose")
                                .resizable()
                                .frame(width: 70, height: 70)

                            HStack(spacing: 4) {
                                Text("가나다")
                                    .font(.pretendardSemiBold(14))
                                    .foregroundColor(.black)

                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 8, height: 12)
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(width: 114, height: 114)
                        .background(Color("brown02"))
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
