//
//  ProfileImageView.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI

// MARK: - ProfileImageView
/// 원격 URL / 로컬 선택 이미지 / 삭제 의도까지 한 곳에서 처리
struct ProfileImageView: View {
    let remoteURL: URL?
    @Binding var selectedImage: UIImage?
    @Binding var didDeleteProfileImage: Bool

    @State private var showCameraMenu = false
    @State private var showImagePicker = false

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                // 표시 우선순위: 선택 이미지 > 원격 이미지 > 기본 이미지
                Group {
                    if let img = selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else if let url = remoteURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Image("default_profile")
                                    .resizable().scaledToFill()
                            }
                        }
                    } else {
                        Image("default_profile")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())

                Button(action: { withAnimation(.easeInOut) { showCameraMenu.toggle() } }) {
                    Image("camera")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                .offset(x: 35, y: 35)
                .zIndex(1)
            }
            .overlay(
                Group {
                    if showCameraMenu {
                        VStack(spacing: 0) {
                            Button(action: {
                                showCameraMenu = false
                                showImagePicker = true
                            }) {
                                Text("프로필 수정")
                                    .font(.pretendardRegular(10))
                                    .padding(7)
                                    .foregroundStyle(Color.black01Dynamic)
                                    .frame(maxWidth: .infinity)
                            }
                            Button(action: {
                                selectedImage = nil
                                didDeleteProfileImage = true
                                showCameraMenu = false
                            }) {
                                Text("프로필 삭제")
                                    .font(.pretendardRegular(10))
                                    .padding(7)
                                    .foregroundStyle(Color.black01Dynamic)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .background(Color.white01Dynamic)
                        .cornerRadius(5)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                        .frame(width: 90)
                        .offset(x: 60, y: 50)
                        .zIndex(2)
                    }
                },
                alignment: .bottomTrailing
            )
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        // 새 이미지를 고르면 삭제 의도는 자동 취소
        .onChange(of: selectedImage != nil, initial: false) { _, hasImage in
            if hasImage { didDeleteProfileImage = false }
        }
    }
}
