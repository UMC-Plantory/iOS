//
//  DiaryCheckImageView.swift
//  Plantory
//
//  Created by 주민영 on 8/21/25.
//

import SwiftUI
import Kingfisher

struct DiaryCheckImageView: View {
    @EnvironmentObject var vm: DiaryCheckViewModel

    @State private var showCameraMenu = false
    @State private var showImagePicker = false

    var body: some View {
        Group {
            if vm.isEditing {
                Button(action: { withAnimation(.easeInOut) { showCameraMenu.toggle() } }) {
                    Group {
                        if let img = vm.selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 215)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray04)
                                
                                Image(systemName: "camera")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(height: 215)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .zIndex(1)
                }
            } else {
                if let url = vm.summary?.diaryImgUrl, let imgUrl = URL(string: url) {
                    KFImage(imgUrl)
                        .placeholder {
                            ProgressView()
                        }
                        .retry(maxCount: 3, interval: .seconds(3))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 215)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    EmptyView()
                }
            }
        }
        .overlay(
            Group {
                if showCameraMenu {
                    VStack(spacing: 0) {
                        Button(action: {
                            showCameraMenu = false
                            showImagePicker = true
                        }) {
                            Text("이미지 수정")
                                .font(.pretendardRegular(10))
                                .padding(7)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            vm.selectedImage = nil
                            vm.didDeleteProfileImage = true
                            showCameraMenu = false
                        }) {
                            Text("이미지 삭제")
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
            },
            alignment: .center
        )
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $vm.selectedImage)
        }
        // 새 이미지를 고르면 삭제 의도는 자동 취소
        .onChange(of: vm.selectedImage != nil, initial: false) { _, hasImage in
            if hasImage { vm.didDeleteProfileImage = false }
        }
    }
}
