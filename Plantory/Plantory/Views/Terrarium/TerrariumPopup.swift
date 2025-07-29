//
//  TerrariumPopup.swift
//  Plantory
//
//  Created by 박정환 on 7/21/25.
//


import SwiftUI

struct TerrariumPopup: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    Image("TerrariumGuideTop")
                        .offset(x: 6, y: -211)
                    Image("TerrariumGuideMiddle")
                        .scaleEffect(1.01)
                        .offset(x: 0, y: -155)
                    Image("TerrariumGuideBottom")
                        .offset(x: 55, y: 140)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: isVisible)

                // 닫기 버튼
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isVisible = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.white)
                                .padding(16)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct TerrariumPopup_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            TerrariumView()
            TerrariumPopup(isVisible: .constant(true))
        }
    }
}
