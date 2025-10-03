//
//  ProfileMemberInfoView.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI

// MARK: - ProfileMemberInfoView (변경 없음)
struct ProfileMemberInfoView: View {
    @ObservedObject var vm: ProfileViewModel
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("회원정보")
                .font(.pretendardSemiBold(18))
                .foregroundStyle(.black01Dynamic)

            Spacer().frame(height: 9)

            InputField(
                title: "닉네임",
                text: $vm.name,
                placeholder: "이름을 입력하세요",
                state: $vm.nameState
            )
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
            DropdownField(
                title: "성별",
                options: ["남성", "여성", "그 외"],
                selection: $vm.gender,
                state: $vm.genderState
            )
            .zIndex(1)

            Spacer().frame(height: 18)
            InputField(
                title: "생년월일",
                text: $vm.birth,
                placeholder: "YYYY-MM-DD",
                state: $vm.birthState
            )

            ReadOnlyInputField(
                title: "이메일",
                text: vm.email,
                message: "소셜 로그인인 경우 이메일 변경이 불가합니다."
            )

            Spacer().frame(height: 48)
            Button(action: onSignOut) {
                HStack {
                    Spacer()
                    Text("회원 탈퇴하기")
                        .font(.pretendardLight(12))
                        .foregroundStyle(.gray08Dynamic)
                        .underline()
                    Spacer()
                }
            }
            Spacer().frame(height: 54)
        }
    }
}
