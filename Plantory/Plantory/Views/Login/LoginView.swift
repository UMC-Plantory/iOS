//
//  LoginView.swift
//  Plantory
//
//  Created by 주민영 on 7/7/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        VStack {
            logoView
            
            Spacer()
                .frame(maxHeight: 94)
            
            VStack(spacing: 22) {
                loginIndicatorView
                
                socialLoginView
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 128)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradient(
                colors: [.white01, .green01],
                center: .center,
                startRadius: 0,
                endRadius: 130
            )
        )
        .ignoresSafeArea()
    }
    
    // 로고+텍스트
    private var logoView: some View {
        VStack(spacing: 0) {
            Image("icon")
                .fixedSize()
            
            Text("기록으로 꽃 피우는 마음 정원")
                .font(.pretendardRegular(20))
                .foregroundStyle(.green08)
                .padding(.top, 24)
            
            Image("logo")
                .fixedSize()
        }
    }
    
    // 간편로그인 인디케이터
    private var loginIndicatorView: some View {
        Text("간편하게 로그인하세요!")
            .font(.pretendardRegular(14))
            .foregroundStyle(.gray08)
    }
    
    // 소셜로그인 버튼뷰
    private var socialLoginView: some View {
        VStack(spacing: 12) {
            Button(action: {
                print("kakaoLogin")
                router.push(.permit)
            }, label: {
                Image("kakaoLogin")
                    .fixedSize()
            })
            
            Button(action: {
                print("appleLogin")
                router.reset()
                router.push(.baseTab)
            }, label: {
                Image("appleLogin")
                    .fixedSize()
            })
        }
    }
}

#Preview {
    LoginView()
        .environment(NavigationRouter())
}
