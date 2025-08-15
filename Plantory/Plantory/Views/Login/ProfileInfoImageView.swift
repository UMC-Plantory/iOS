//
//  ProfileInfoImageView.swift
//  Plantory
//
//  Created by 주민영 on 8/12/25.
//

import SwiftUI

struct ProfileInfoImageView: View {
    // 상위에서 소유/관리하는 이미지 바인딩
    @Binding var selectedImage: UIImage?

    // 내부 UI 상태
    @State private var showCameraMenu = false
    @State private var showImagePicker = false

    // 기본 이미지 이름 (필요 시 커스터마이즈)
    var placeholderImageName: String = "default_profile"

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Group {
                    if let img = selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(placeholderImageName)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())

                Button {
                    withAnimation(.easeInOut) { showCameraMenu.toggle() }
                } label: {
                    Image("camera")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                .offset(x: 35, y: 35)
                .zIndex(1)
            }
            .overlay(alignment: .bottomTrailing) {
                if showCameraMenu {
                    VStack(spacing: 0) {
                        Button {
                            showCameraMenu = false
                            showImagePicker = true
                        } label: {
                            Text("프로필 수정")
                                .font(.pretendardRegular(10))
                                .padding(7)
                                .frame(maxWidth: .infinity)
                        }
                        Button {
                            selectedImage = nil
                            showCameraMenu = false
                        } label: {
                            Text("프로필 삭제")
                                .font(.pretendardRegular(10))
                                .padding(7)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(5)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                    .frame(width: 90)
                    .offset(x: 60, y: 50)
                    .zIndex(2)
                    .foregroundStyle(.black)
                }
            }
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            // 이미 가지고 있는 ImagePicker 사용
            ImagePicker(image: $selectedImage)
        }
    }
}
