//
// ProfileManageView.swift
// Annotated for maintainability
//
// 이 파일은 사용자 프로필 관리 화면을 구성하는 SwiftUI 뷰 모듈입니다.
// 주요 구조와 상태 관리를 이해하기 쉽도록 주석을 추가했습니다.

import SwiftUI
import UIKit

// MARK: - ProfileManageView
/// 프로필 관리 화면의 최상위 뷰 구조를 정의합니다.
struct ProfileManageView: View {
    // 환경으로부터 dismiss 액션을 가져와 모달 혹은 네비게이션 스택에서 뒤로가기 처리에 사용합니다.
    @Environment(\.dismiss) private var dismiss
    
    // 뷰모델 인스턴스를 생성하여 프로필 데이터와 상태를 관리합니다.
    @StateObject private var vm = ProfileViewModel()
    
    // 탈퇴 팝업 표시 여부를 제어하는 상태 변수입니다.
    @State private var isShowingSignOutPopup = false

    var body: some View {
        ZStack {
            // 스크롤 가능한 메인 콘텐츠
            ScrollView(.vertical, showsIndicators: false) {
                profileContent
            }

            // 탈퇴 팝업을 필요 시 최상위에 표시
            if isShowingSignOutPopup {
                signOutPopup
            }
        }
    }

    // MARK: - Main Content
    /// 프로필 관리 메인 콘텐츠 레이아웃 및 네비게이션 바 설정
    private var profileContent: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 15)
            ProfileImageView()                      // 프로필 이미지 섹션
            ProfileMemberInfoView(vm: vm) {
                // 탈퇴 버튼 클릭 시 팝업 토글
                isShowingSignOutPopup = true
            }
        }
        .customNavigation(
            title: "프로필 관리",
            leading: backButton                  // 커스텀 뒤로가기 버튼
        )
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden()       // 시스템 기본 뒤로가기 숨김
    }

    // MARK: - Back Button
    /// 네비게이션 커스텀 뒤로가기 버튼
    private var backButton: some View {
        Button(action: dismiss.callAsFunction) {
            Image("leftChevron").fixedSize()
        }
    }

    // MARK: - Sign Out PopUp
    /// 계정 탈퇴 확인 팝업 뷰
    private var signOutPopup: some View {
        PopUp(
            title: "계정을 탈퇴하시겠습니까?",
            message: "계정 탈퇴 시, 계정과 관련된 모든 권한과 정보가 삭제됩니다.",
            confirmTitle: "탈퇴하기",
            cancelTitle: "취소",
            onConfirm: {
                // TODO: 실제 탈퇴 처리 로직 연결
                print("회원 탈퇴 확인 버튼 클릭")
                isShowingSignOutPopup = false
            },
            onCancel: {
                // 팝업 닫기
                isShowingSignOutPopup = false
            }
        )
        .zIndex(1)                             // 팝업 레이어 우선순위 설정
    }
}

// MARK: - ProfileImageView
/// 프로필 이미지 표시 및 수정 기능을 제공하는 뷰
struct ProfileImageView: View {
    // 카메라 메뉴 (수정/삭제) 표시 여부
    @State private var showCameraMenu = false
    // 이미지 피커 시트 표시 여부
    @State private var showImagePicker = false
    // 선택된 이미지 저장
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Group {
                    if let img = selectedImage {
                        // 사용자가 선택한 이미지를 원본 비율 유지하며 표시
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // 기본 프로필 이미지 표시
                        Image("default_profile")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())          // 원형 마스크 적용

                Button(action: {
                    // 애니메이션과 함께 카메라 메뉴 토글
                    withAnimation(.easeInOut) {
                        showCameraMenu.toggle()
                    }
                }) {
                    Image("camera")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                .offset(x: 35, y: 35)
                .zIndex(1)
            }
            .overlay(
                // 카메라 메뉴: 프로필 수정/삭제 옵션
                Group {
                    if showCameraMenu {
                        VStack(spacing: 0) {
                            Button(action: {
                                showCameraMenu = false
                                showImagePicker = true    // 이미지 피커 호출
                            }) {
                                Text("프로필 수정")
                                    .font(.pretendardRegular(10))
                                    .padding(7)
                                    .frame(maxWidth: .infinity)
                            }
                            Button(action: {
                                selectedImage = nil        // 이미지 삭제
                                showCameraMenu = false
                            }) {
                                Text("프로필 삭제")
                                    .font(.pretendardRegular(10))
                                    .padding(7)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(6)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                        .frame(width: 90)
                        .offset(x: 60, y: 50)
                        .zIndex(2)
                        .foregroundStyle(.black)
                    }
                },
                alignment: .bottomTrailing
            )
            Spacer()
        }
        // 이미지 피커 시트 연결
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

// MARK: - ProfileMemberInfoView
/// 사용자 정보 입력 및 표시 영역을 구성하는 뷰
struct ProfileMemberInfoView: View {
    @ObservedObject var vm: ProfileViewModel  // 프로필 데이터 관리 뷰모델
    let onSignOut: () -> Void                  // 탈퇴 액션 콜백

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("회원정보")
                .font(.pretendardSemiBold(18))      // 제목 스타일

            Spacer().frame(height: 9)
            // 이름 입력 필드: 뷰모델 바인딩
            InputField(
                title: "이름",
                text: $vm.name,
                placeholder: "이름을 입력하세요",
                state: $vm.nameState
            )
            // 아이디 입력 필드: 뷰모델 바인딩
            InputField(
                title: "아이디",
                text: $vm.id,
                placeholder: "아이디를 입력하세요",
                state: $vm.idState
            )

            Spacer().frame(height: 18)
            Text("개인정보")
                .font(.pretendardSemiBold(18))

            Spacer().frame(height: 9)
            // 성별 선택 드롭다운
            DropdownField(
                title: "성별",
                options: ["남성", "여성", "그 외"],
                selection: $vm.gender,
                state: $vm.genderState
            )
            .zIndex(1)                             // 드롭다운 레이어 우선순위

            Spacer().frame(height: 18)
            // 생년월일 입력 필드
            InputField(
                title: "생년월일",
                text: $vm.birth,
                placeholder: "YYYY.MM.DD",
                state: $vm.birthState
            )

            // 이메일 읽기 전용 필드
            ReadOnlyInputField(
                title: "이메일",
                text: vm.email,
                message: "소셜 로그인인 경우 이메일 변경이 불가합니다."
            )

            Spacer().frame(height: 30)
            // 탈퇴 버튼: onSignOut 호출
            Button(action: onSignOut) {
                HStack {
                    Spacer()
                    Text("회원 탈퇴하기")
                        .font(.PretendardLight(12))
                        .foregroundStyle(.gray08)
                        .underline()
                    Spacer()
                }
            }

            Spacer().frame(height: 30)
            // 취소/저장 버튼
            ActionButtons(onCancel: {}, onSave: {})
        }
    }
}

// MARK: - ActionButtons
/// 취소 및 저장 버튼을 가로로 배치하는 뷰 컴포넌트
struct ActionButtons: View {
    let onCancel: () -> Void   // 취소 콜백
    let onSave: () -> Void     // 저장 콜백

    var body: some View {
        HStack(spacing: 8) {
            // 취소 버튼 스타일 및 동작
            Button(action: onCancel) {
                Text("취소")
                    .font(.pretendardMedium(14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray06)
                    )
            }

            // 저장 버튼 스타일 및 동작
            Button(action: onSave) {
                Text("저장")
                    .font(.pretendardMedium(14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green06)
                    )
            }
        }
        .padding(.vertical, 16)  // 버튼 그룹 상하 여백
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

            HStack {
                Text(text)
                    .font(.pretendardRegular(14))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray04)
                    .stroke(Color.gray08, lineWidth: 1)
            )

            // 안내 메시지가 있을 경우 표시
            if let message = message {
                Text(message)
                    .font(.PretendardLight(12))
                    .foregroundColor(Color.gray08)
            }
        }
    }
}

#Preview {
    NavigationStack { ProfileManageView() }
}
