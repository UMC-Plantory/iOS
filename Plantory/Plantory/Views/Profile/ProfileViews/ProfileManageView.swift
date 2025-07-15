// ProfileManageView.swift
// Plantory

import SwiftUI

// MARK: - View and Components
struct ProfileManageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        VStack(spacing: 24) {
            ProfileImageView()
            ProfileMemberInfoView(vm: vm)
        }
        .customNavigation(title: "프로필 관리", leading: Button(action: dismiss.callAsFunction) {
            Image("leftChevron").fixedSize()
        })
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden()
    }
}

struct ProfileImageView: View {
    var body: some View {
    }
}

struct ProfileMemberInfoView: View {
    @ObservedObject var vm: ProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            InputField(
                title: "이름",
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
            InputField(
                title: "생년월일",
                text: $vm.birth,
                placeholder: "YYYY.MM.DD",
                state: $vm.birthState
            )
        }
    }
}

#Preview {
    NavigationStack {
        ProfileManageView()
    }
}
