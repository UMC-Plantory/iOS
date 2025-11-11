import SwiftUI
import UIKit

// MARK: - ProfileManageView
struct ProfileManageView: View {
    private let container: DIContainer
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionManager: SessionManager

    @StateObject private var vm: ProfileViewModel

    // 이미지/삭제 의도 상태는 상위에서 관리
    @State private var selectedImage: UIImage? = nil
    @State private var didDeleteProfileImage = false

    @State private var isShowingSignOutPopup = false

    init(container: DIContainer) {
        self.container = container
        _vm = StateObject(wrappedValue: ProfileViewModel(container: container))
    }

    var body: some View {
        ZStack {
            Color.adddiarybackground.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Divider().background(.gray04)
                
                ScrollView(.vertical, showsIndicators: false) {
                    profileContent
                }
            }
        }
        .popup(
            isPresented: $isShowingSignOutPopup,
            title: "계정을 탈퇴하시겠습니까?",
            message: "계정 탈퇴 시, 계정과 관련된 모든 권한과 정보가 삭제됩니다.",
            confirmTitle: "탈퇴하기",
            cancelTitle: "취소",
            onConfirm: {
                vm.withdrawAccount()
                container.navigationRouter.reset()
                withAnimation(.easeInOut(duration: 0.3)) {
                    sessionManager.isLoggedIn = false
                }
            }
        )
        .task {
            UIApplication.shared.hideKeyboard()
        }
    }

    // MARK: - Main Content
    private var profileContent: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 15)
            // 원격 URL + 선택 이미지 + 삭제 의도 모두 ProfileImageView로 전달
            ProfileImageView(
                remoteURL: URL(string: vm.profileImgUrl),
                selectedImage: $selectedImage,
                didDeleteProfileImage: $didDeleteProfileImage
            )

            ProfileMemberInfoView(vm: vm) {
                withAnimation(.spring()) { isShowingSignOutPopup = true }
            }

            // 취소/저장 버튼
            ActionButtons(
                onCancel: {
                    // 필요 시 로컬 변경 리셋
                    selectedImage = nil
                    didDeleteProfileImage = false
                    dismiss()
                },
                onSave: {
                    // 저장 시: 폼 필드들은 vm 바인딩으로 이미 연결됨
                    vm.saveProfileChanges(selectedImage: selectedImage, didDeleteProfileImage: didDeleteProfileImage)
                    didDeleteProfileImage = false
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .customNavigation(
            title: "프로필 관리",
            leading: backButton
        )
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden()
        .loadingIndicator(vm.isLoading)
    }

    // MARK: - Back Button
    private var backButton: some View {
        Button(action: dismiss.callAsFunction) {
            Image("leftChevron")
                .renderingMode(.template)
                .foregroundStyle(.black01Dynamic)
                .fixedSize()
        }
    }
}


// MARK: - ActionButtons (변경 없음)
struct ActionButtons: View {
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onCancel) {
                Text("취소")
                    .font(.pretendardMedium(14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray07Dynamic)
                    )
            }
            Button(action: onSave) {
                Text("저장")
                    .font(.pretendardMedium(14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.green06Dynamic)
                    )
            }
        }
    }
}

// MARK: - ReadOnlyInputField
/// 읽기 전용 입력 필드 컴포넌트
struct ReadOnlyInputField: View {
    let title: String
    let text: String
    let message: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.pretendardRegular(14))
                .foregroundStyle(Color.black01Dynamic)

            HStack {
                Text(text)
                    .font(.pretendardRegular(14))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray04Dynamic)
                    .stroke(Color.gray08, lineWidth: 1)
            )

            // 안내 메시지가 있을 경우 표시
            if let message = message {
                Text(message)
                    .font(.pretendardLight(12))
                    .foregroundColor(Color.gray08Dynamic)
            }
        }
    }
}

#Preview {
    NavigationStack { ProfileManageView(container: .init()) }
}
