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
        ZStack{
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            Image("Tutorial")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)

            // 닫기 버튼
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
                .padding(.top, 47)
                .padding(.trailing, 16)
                Spacer()
            }
        }
    }
}


struct TerrariumPopup_Previews: PreviewProvider {
    static var previews: some View {
        TerrariumPopup()
    }
}
