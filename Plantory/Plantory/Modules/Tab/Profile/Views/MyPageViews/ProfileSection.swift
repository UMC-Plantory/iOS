//
//  ProfileSection.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI

// MARK: — 프로필 섹션 (뷰는 그리기만: 값은 전부 VM에서 완성)
struct ProfileSection: View {
    let nickname: String
    let userCustomId: String
    let profileImageURL: URL?
    let action: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            // 원형 프로필 이미지
            if let url = profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                    default:
                        Image("default_profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                    }
                }
            } else {
                Image("default_profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(nickname.isEmpty ? " " : nickname)
                    .font(.pretendardMedium(20))
                    .foregroundStyle(.black01Dynamic)
                Text(userCustomId.isEmpty ? " " : userCustomId)
                    .font(.pretendardRegular(16))
                    .foregroundColor(.gray09Dynamic)
            }

            Spacer()
            Button(action: action) {
                Text("프로필 관리")
                    .font(.pretendardMedium(16))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.green04)
                    .cornerRadius(5)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 28)
    }
}
