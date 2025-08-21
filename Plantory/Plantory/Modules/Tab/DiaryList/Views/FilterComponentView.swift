//
//  FilterComponents.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//
// FilterView 에서 필요한 컴포넌트들을 모아놓은 파일입니다. 
import SwiftUI

/// 나열 방식 선택 버튼
struct OrderButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(isSelected ? "radio_green" : "radio_gray")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? Color("green04") : .gray)

                Text(title)
                    .foregroundColor(Color("black01"))
                    .font(.pretendardRegular(16))
            }
        }
    }
}

/// 감정 선택 태그
struct EmotionTag: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(emotion.rawValue)
            .font(.pretendardRegular(14))
            .fixedSize()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color("green04") : Color.white)
            .foregroundColor(isSelected ? .white : .gray)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(20)
            .onTapGesture {
                action()
            }
    }
}
