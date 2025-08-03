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
                HStack(spacing: 96) {
                    Button(action: {
                        withAnimation {
                            selectedSegment = .terrarium
                            onTabSelected?(.terrarium)
                        }
                    }) {
                        Text(TerrariumTab.terrarium.rawValue)
                            .font(.pretendardSemiBold(20))
                            .foregroundColor(selectedSegment == .terrarium ? Color("green06") : Color("gray08"))
                    }

                    Button(action: {
                        withAnimation {
                            selectedSegment = .myGarden
                            onTabSelected?(.myGarden)
                        }
                    }) {
                        Text(TerrariumTab.myGarden.rawValue)
                            .font(.pretendardSemiBold(20))
                            .foregroundColor(selectedSegment == .myGarden ? Color("green06") : Color("gray08"))
                    }
                }
                .padding(.bottom, 16)
            }

            HStack {
                if selectedSegment == .terrarium {
                    Rectangle()
                        .fill(Color("green06"))
                        .frame(width: 134, height: 4)
                        .cornerRadius(20)
                        .padding(.leading, 50)
                        .offset(y: 1)
                } else if selectedSegment == .myGarden {
                    Rectangle()
                        .fill(Color("green06"))
                        .frame(width: 134, height: 4)
                        .cornerRadius(20)
                        .padding(.leading, 216)
                        .offset(y: 1)
                }
            }
            .animation(.easeInOut, value: selectedSegment)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct CustomSegmentView_Previews: View {
    @State private var selectedSegment: TerrariumTab = .terrarium

    var body: some View {
        CustomSegmentView(selectedSegment: $selectedSegment)
    }
}

#Preview {
    CustomSegmentView_Previews()
}
