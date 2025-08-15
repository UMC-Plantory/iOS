//
//  LoginView.swift
//  Plantory
//
//  Created by 주민영 on 7/7/25.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var container: DIContainer
    
    // MARK: - Property
    
    @State var viewModel: LoginViewModel
    
    // MARK: - Init

    /// DIContainer와 앱 흐름 ViewModel(AppFlowViewModel)을 주입받아 초기화
    init(
        container: DIContainer,
    ) {
        self.viewModel = .init(container: container)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            logoView
                //FIX-ME: 개발용
                .onTapGesture {
                    container.navigationRouter.push(.baseTab)
                }
            
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
        .navigationBarBackButtonHidden()
        .toastView(toast: $viewModel.toast)
        .loadingIndicator(viewModel.isLoading)
    }
    
    // MARK: - Top Contents
    
    /// 로고+텍스트
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
    
    // MARK: - Bottom Contents
    
    /// 간편로그인 인디케이터
    private var loginIndicatorView: some View {
        Text("간편하게 로그인하세요!")
            .font(.pretendardRegular(14))
            .foregroundStyle(.gray08)
    }
    
    /// 소셜로그인 버튼뷰
    private var socialLoginView: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.kakaoLogin()
                }
            }, label: {
                Image("kakaoLogin")
                    .fixedSize()
            })
            
            Button(action: {
                Task {
                    if let window = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.windows.first {
                        await viewModel.appleLogin(presentationAnchor: window)
                    }
                }
            }, label: {
                Image("appleLogin")
                    .fixedSize()
            })
        }
    }
}

#Preview {
    LoginView(container: .init())
}
