//
//  ProfileInfoView.swift
//  Plantory
//
//  Created by 주민영 on 8/9/25.
//

import SwiftUI

struct ProfileInfoView: View {
    
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var sessionManager: SessionManager
    
    // MARK: - Property
    
    @StateObject var viewModel: ProfileInfoViewModel
    
    // 로그인 화면으로 돌아가는 팝업 여부를 제어하는 상태 변수
    @State private var isShowingGoToLoginPopup = false
    
    // MARK: - Init

    /// DIContainer와 앱 흐름 ViewModel(AppFlowViewModel)을 주입받아 초기화
    init(container: DIContainer) {
        _viewModel = StateObject(
            wrappedValue: ProfileInfoViewModel(container: container)
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        // 메인 콘텐츠
        profileInfoView
            .popup(
                isPresented: $isShowingGoToLoginPopup,
                title: "로그인 화면으로 돌아가시겠습니까?",
                message: "로그인 화면으로 돌아가면 작성 중인 내용이 모두 삭제됩니다.",
                confirmTitle: "돌아가기",
                cancelTitle: "취소",
                onConfirm: {
                    // 로그인 화면으로 이동한 후 팝업 닫기
                    container.navigationRouter.reset()
                }
            )
            .toastView(toast: $viewModel.toast)
            .loadingIndicator(viewModel.isLoading)
    }
    
    private var profileInfoView: some View {
        VStack(spacing: 0) {
            headerView
            
            if viewModel.isCompleted {
                NothingView(
                    mainText: "회원가입이 완료 되었어요!",
                    subText: "플랜토리의 다양한 서비스를 이용해보세요.",
                    buttonTitle: "홈으로 이동하기",
                    buttonAction: {
                        sessionManager.isLoggedIn = true
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                AdaptiveScrollView(topPadding: 24, bottomPadding: 72) {
                    profileView
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
    }
    
    private var profileView: some View {
        VStack(spacing: 32) {
            Text("플랜토리 계정 프로필을 설정해 주세요.")
                .font(.pretendardSemiBold(16))
                .foregroundStyle(.green06)
            
            ProfileInfoImageView(selectedImage: $viewModel.selectedImage)
            
            infoView
                .zIndex(10)
            
            HStack {
                Spacer()
                
                MainMiddleButton(
                    text: "확인",
                    isDisabled: !viewModel.isFormValid,
                    action: {
                        Task {
                            await viewModel.didTapNextButton()
                        }
                    }
                )
            }
            .zIndex(5)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    // 로그인으로 돌아가기 팝업 띄우기
                    withAnimation(.spring()) { isShowingGoToLoginPopup = true }
                }, label: {
                    Image("leftChevron")
                        .fixedSize()
                })
                
                Spacer()
            }
            .overlay {
                Image("logo_text")
                    .fixedSize()
            }
            
            Divider()
                .frame(height: 1)
                .foregroundStyle(.gray06)
        }
    }
    
    private var infoView: some View {
        VStack(spacing: 18) {
            InputField(
                title: "닉네임",
                text: $viewModel.name,
                placeholder: "닉네임을 입력하세요",
                state: $viewModel.nameState
            )
            
            InputField(
                title: "아이디",
                text: $viewModel.id,
                placeholder: "아이디를 입력하세요",
                state: $viewModel.idState
            )
            
            InputField(
                title: "생년월일",
                text: $viewModel.birth,
                placeholder: "0000-00-00",
                state: $viewModel.birthState
            )
            .keyboardType(.numbersAndPunctuation)
            
            DropdownField(
                title: "성별",
                options: ["남성", "여성", "선택 안 함"],
                selection: $viewModel.gender,
                state: $viewModel.genderState
            )
        }
    }
}

#Preview {
    ProfileInfoView(container: DIContainer())
}
