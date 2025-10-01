//
//  ThemePopupView.swift
//  Plantory
//
//  Created by 이효주 on 10/1/25.
//

import SwiftUI

struct ThemePopup: View {
    
    @State private var appearScale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background Blur
            BlurBackground()
            
                VStack {
                    Spacer()
                    // Buttons
                    VStack(spacing: 24) {
                        // Light Mode Button
                        Button(action: {
                            // Action for Light Mode
                        }) {
                            Text("라이트 모드")
                                .font(.pretendardBold(16))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(100)
                        }
                        .padding(.horizontal, 45)
                        
                        // Dark Mode Button
                        Button(action: {
                            // Action for Dark Mode
                        }) {
                            Text("다크 모드")
                                .font(.pretendardBold(16))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(100)
                        }
                        .padding(.horizontal, 45)
                    }
                    Spacer()
                }
                .scaleEffect(appearScale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        appearScale = 1.0
                        opacity = 1.0
                    }
                }
        }
    }
}


#Preview {
    ThemePopup()
}
