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
                .padding(.bottom, 1)

            HStack(alignment: .center) {
                HStack(spacing: 32) {
                    VStack {
                        Button(action: {
                            withAnimation {
                                selectedSegment = .terrarium
                                onTabSelected?(.terrarium)
                            }
                        }) {
                            VStack{
                                Text(TerrariumTab.terrarium.rawValue)
                                    .font(.pretendardSemiBold(20))
                                    .foregroundColor(selectedSegment == .terrarium ? Color("green06") : Color("gray08"))
                                    .padding(.bottom, 14)
                                
                                if selectedSegment == .terrarium {
                                    Rectangle()
                                        .fill(Color("green06"))
                                        .frame(width: 134, height: 4)
                                        .cornerRadius(20)
                                } else {
                                    Color.clear.frame(height: 4)
                                }
                            }
                        }
                    }
                    .frame(width: 134)

                    VStack {
                        Button(action: {
                            withAnimation {
                                selectedSegment = .myGarden
                                onTabSelected?(.myGarden)
                            }
                        }) {
                            VStack{
                                Text(TerrariumTab.myGarden.rawValue)
                                    .font(.pretendardSemiBold(20))
                                    .foregroundColor(selectedSegment == .myGarden ? Color("green06") : Color("gray08"))
                                    .padding(.bottom, 14)
                                
                                if selectedSegment == .myGarden {
                                    Rectangle()
                                        .fill(Color("green06"))
                                        .frame(width: 134, height: 4)
                                        .cornerRadius(20)
                                } else {
                                    Color.clear.frame(height: 4)
                                }
                            }
                        }
                    }
                    .frame(width: 134)
                }
                .padding(.top, 16)
            }
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
