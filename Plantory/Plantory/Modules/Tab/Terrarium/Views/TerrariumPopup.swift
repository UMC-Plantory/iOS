//
//  TerrariumPopup.swift
//  Plantory
//
//  Created by 박정환 on 7/21/25.
//


import SwiftUI

struct TerrariumPopup: View {
    @EnvironmentObject var popupManager: PopupManager
    
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack {
                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                // tutorial1: top-left, responsive insets
                Image("tutorial1")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, h * 0.02)
                    .padding(.leading, w * 0.36)

                // tutorial2: centered, responsive vertical offset
                Image("tutorial2")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .offset(y: -h * 0.186)

                // tutorial3: lower-left, responsive insets
                Image("tutorial3")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, h * 0.653)
                    .padding(.leading, w * 0.366)

                // Close button (top-trailing), sized and inset relatively
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            popupManager.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, h * 0.04)
                    .padding(.trailing, w * 0.04)

                    Spacer()
                }
            }
        }
    }
}


struct TerrariumPopup_Previews: PreviewProvider {
    static var previews: some View {
        TerrariumPopup()
    }
}
