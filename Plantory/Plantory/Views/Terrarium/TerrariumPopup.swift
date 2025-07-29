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
            ZStack{
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                Image("tutorial")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)

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
        TerrariumPopup(isVisible: .constant(true))
    }
}
