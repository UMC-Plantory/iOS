//
//  SplashView.swift
//  Plantory
//
//  Created by 주민영 on 11/11/25.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.green01
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
            
            Image(.icon)
        }
    }
}

#Preview {
    SplashScreenView()
}
