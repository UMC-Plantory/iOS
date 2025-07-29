//
//  CustomSegmentView.swift
//  Plantory
//
//  Created by 박정환 on 7/11/25.
//

import SwiftUI


struct CustomSegmentView: View {
    @Binding var selectedSegment: TerrariumTab
    var onTabSelected: ((TerrariumTab) -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color("green04"))
                .frame(height: 1)

            HStack(alignment: .center) {
                HStack(spacing: 31) {
                    Button(action: {
                        withAnimation {
                            selectedSegment = .terrarium
                            onTabSelected?(.terrarium)
                        }
                    }) {
                        Text(TerrariumTab.terrarium.rawValue)
                            .font(.pretendardSemiBold(20))
                            .foregroundColor(selectedSegment == .terrarium ? Color("black01") : Color("gray08"))
                    }

                    Button(action: {
                        withAnimation {
                            selectedSegment = .myGarden
                            onTabSelected?(.myGarden)
                        }
                    }) {
                        Text(TerrariumTab.myGarden.rawValue)
                            .font(.pretendardSemiBold(20))
                            .foregroundColor(selectedSegment == .myGarden ? Color("black01") : Color("gray08"))
                    }
                }
                .padding(.leading, 22)
                .padding(.bottom, 16)

                Spacer()

                Button(action: {
                    // 점 3개 버튼 액션
                }) {
                    Image("Dot Menu")
                }
                .padding(.trailing, 16)
            }

            HStack {
                if selectedSegment == .terrarium {
                    Rectangle()
                        .fill(Color("green06"))
                        .frame(width: 76, height: 4)
                        .cornerRadius(20)
                        .padding(.leading, 18)
                        .offset(y: 1)
                } else if selectedSegment == .myGarden {
                    Rectangle()
                        .fill(Color("green06"))
                        .frame(width: 76, height: 4)
                        .cornerRadius(20)
                        .padding(.leading, 122)
                        .offset(y: 1)
                }
            }
            .animation(.easeInOut, value: selectedSegment)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    CustomSegmentView(selectedSegment: .constant(.terrarium))
}
