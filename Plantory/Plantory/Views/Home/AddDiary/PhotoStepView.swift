//
//  PhotoStepView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI
import PhotosUI

struct PhotoStepView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        Spacer()
            .frame(height:20)
        VStack {
            Text("오늘의 사진을 선택한다면 무엇인가요?")
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.diaryfont)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ZStack {
                // 기본 배경 (회색 박스)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray04)
                    .frame(width: 205,height: 207)
                    .overlay {
                        // 이미지가 있으면 가장 최근 이미지를 꽉 차게 표시
                        if let firstImage = selectedImages.first {
                            Image(uiImage: firstImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }

                // 텍스트 위에 이미지 추가 (이미지가 없을 경우 텍스트만 표시)
                if selectedImages.isEmpty {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
                        VStack{
                            Image(.photo)
                                .resizable()
                                .frame(width: 32, height: 32)

                            Text("사진을 업로드해 주세요")
                                .font(.pretendardRegular(16))
                                .foregroundStyle(.gray08)
                        }
                    }
                    .zIndex(1)
                }
            }
            .frame(height: 300)
        }
        .padding()
        .onChange(of: selectedItems) { oldItems, newItems in
            selectedImages.removeAll()
            for item in newItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
            }
        }
        
        Spacer()
            .frame(height:20)
        
        
    }
}
