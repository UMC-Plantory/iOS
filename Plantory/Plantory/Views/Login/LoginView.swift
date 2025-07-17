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
                .frame(maxHeight: 264)
            
            VStack(spacing: 27) {
                loginIndicatorView
                
                socialLoginView
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 160)
    }
    
    // 로고+텍스트
    private var logoView: some View {
        VStack(spacing: 14.5) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 224, height: 52)
            
            Text("기록으로 꽃 피우는 마음 정원")
                .font(.pretendardRegular(16))
                .foregroundStyle(.green08)
        }
    }
    
    // 간편로그인 인디케이터
    private var loginIndicatorView: some View {
        HStack(spacing: 28) {
            VStack {
                Divider()
                    .foregroundStyle(.gray08)
                    .frame(height: 1)
            }
            
            Text("간편로그인")
                .font(.pretendardRegular(14))
                .foregroundStyle(.gray08)
            
            VStack {
                Divider()
                    .foregroundStyle(.gray08)
                    .frame(height: 1)
            }
        }
    }
    
    // 소셜로그인 버튼뷰
    private var socialLoginView: some View {
        HStack(spacing: 12) {
            Button(action: {
                print("apple_login")
                router.reset()
                router.push(.baseTab)
            }, label: {
                Image("apple_login")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 54, height: 54)
            })
            
            Button(action: {
                print("kakao_login")
                router.push(.permit)
            }, label: {
                Image("kakao_login")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 54, height: 54)
            })
        }
    }
}

#Preview {
    LoginView()
        .environment(NavigationRouter())
}
