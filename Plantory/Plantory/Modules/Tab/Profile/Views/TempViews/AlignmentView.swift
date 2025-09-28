//
//  Alignment.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI

struct AlignmentView: View {
    @Binding var isNew: Bool
    let selectedCount: Int
    @State private var showMenu = false

    var body: some View {
        HStack {
            Text("총 \(selectedCount)개 선택됨")
                .font(.pretendardRegular(14))
            Spacer()
            // 1) 토글 버튼만 HStack 안에
            Button {
                showMenu.toggle()
            } label: {
                HStack(spacing: 4) {
                    Text(isNew ? "최신순" : "오래된순")
                        .font(.pretendardRegular(14))
                        .foregroundStyle(.black01Dynamic)
                        .offset(x: 15)
                    if showMenu {
                        Image("Up")
                    } else {
                        Image("Down")
                    }
                }
                .background(Color.white)
            }
        }

        // 2) overlay 로 메뉴를 얹고 layout 에 영향 주지 않기
        .overlay(
            Group {
                if showMenu {
                    VStack(spacing: 0) {
                        Button {
                            isNew = true
                            showMenu = false
                        } label: {
                            Text("최신순")
                                .font(isNew ? .pretendardSemiBold(10) : .pretendardRegular(10))
                                .foregroundColor(isNew ? .green06 : .black)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button {
                            isNew = false
                            showMenu = false
                        } label: {
                            Text("오래된순")
                                .font(!isNew ? .pretendardSemiBold(10) : .pretendardRegular(10))
                                .foregroundColor(!isNew ? .green06 : .black)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 0, x: 2, y: 2)
                    .frame(width: 80)
                    .offset(x: 0, y: 40) // 버튼 바로 아래에 위치
                }
            },
            alignment: .topTrailing   // HStack의 topTrailing 기준
        )
        // 3) 다른 형제 뷰들 위로 띄우기
        .zIndex(showMenu ? 1 : 0)
    }
}
