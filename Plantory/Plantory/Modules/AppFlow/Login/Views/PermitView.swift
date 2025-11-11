//
//  PermitView.swift
//  Plantory
//
//  Created by 주민영 on 7/8/25.
//

import SwiftUI

struct PermitView: View {
    
    @EnvironmentObject var loginRouter: LoginRouter
    
    // MARK: - Property
    
    @State var viewModel: PermitViewModel
    
    // MARK: - Init

    /// DIContainer와 앱 흐름 ViewModel(AppFlowViewModel)을 주입받아 초기화
    init(
        container: DIContainer,
        loginRouter: LoginRouter
    ) {
        self.viewModel = .init(container: container, loginRouter: loginRouter)
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                VStack(alignment: .leading) {
                    topTextView
                    
                    VStack(alignment: .leading, spacing: 20) {
                        allToggle
                        
                        Divider()
                            .foregroundStyle(.gray06Dynamic)
                        
                        detailedToggles
                    }
                    .padding(.top, 44)
                    
                    Spacer()
                }
                
                MainMiddleButton(
                    text: "다음",
                    isDisabled: !(viewModel.termsOfServicePermit && viewModel.informationPermit),
                    action: {
                        Task {
                            try await viewModel.nextButtonTapped()
                        }
                    }
                )
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
        .padding(.top, 10)
        .navigationBarBackButtonHidden(true)
        .background(Color.white01Dynamic)
        .customNavigation(
            leading:
                Button(action: {
                    print("뒤로가기")
                    loginRouter.pop()
                }, label: {
                    Image("leftChevron")
                        .renderingMode(.template)
                        .foregroundStyle(.black01Dynamic)
                        .fixedSize()
                })
        )
        .toastView(toast: $viewModel.toast)
        .loadingIndicator(viewModel.isLoading)
    }
    
    private var topTextView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("서비스 이용 동의")
                .font(.pretendardSemiBold(24))
                .foregroundStyle(.black01Dynamic)
            
            Text("약관을 확인 후 버튼을 체크해주세요")
                .font(.pretendardRegular(14))
                .foregroundStyle(.gray10)
        }
    }
    
    private var allToggle: some View {
        Toggle("약관 전체 동의", isOn: $viewModel.allPermit)
            .toggleStyle(CheckboxToggleStyle(style: .circle))
            .font(.pretendardSemiBold(18))
            .foregroundStyle(.black01Dynamic)
    }
    
    private var detailedToggles: some View {
        VStack(alignment: .leading, spacing: 40) {
            ForEach(permitItems, id: \.id) { item in
                HStack {
                    Toggle(item.title, isOn: item.binding)
                        .toggleStyle(CheckboxToggleStyle(style: .circle))
                        .font(.pretendardRegular(16))
                        .foregroundStyle(.gray10Dynamic)
                    
                    Spacer()
                    
                    Button(action: {
                        loginRouter.push(.policy(num: item.num))
                    }, label: {
                        Image("rightChevron")
                            .renderingMode(.template)
                            .foregroundStyle(.gray10Dynamic)
                            .fixedSize()
                    })
                }
            }
        }
        .padding(.top, 5)
    }
    
    var permitItems: [PermitItem] {
        [
            PermitItem(num: 0, title: "(필수) 서비스 이용약관", binding: $viewModel.termsOfServicePermit),
            PermitItem(num: 1, title: "(필수) 개인정보 수집/이용동의", binding: $viewModel.informationPermit),
            PermitItem(num: 2, title: "(선택) 마케팅 수신 동의", binding: $viewModel.marketingPermit)
        ]
    }
}
