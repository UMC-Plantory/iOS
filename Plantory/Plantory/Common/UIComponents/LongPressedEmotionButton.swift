//
//  LongPressedEmotionButton.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

/// 꾹 누르는 순간부터 tappedImage를 보여주고, 손을 뗐을 때 action()을 호출하는 재사용 버튼
struct LongPressEmotionButton: View {
    let untappedImage: ImageResource   // 기본 이미지
    let tappedImage: ImageResource     // 누르고 있는 동안 보여줄 이미지
    let label: String               // 버튼 아래 텍스트
    let action: () -> Void          // 손 뗄 때 실행할 로직

    @State private var isPressing = false

    var body: some View {
        VStack(spacing: 4) {
            Image(isPressing ? tappedImage : untappedImage)
            Text(label)
                .font(.pretendardRegular(14))
                .foregroundStyle(isPressing ? .adddiaryfont : .gray08)
        }
        .frame(width: 60)                   // 터치 영역 고정
        .contentShape(Rectangle())          // 빈 공간도 터치 가능
        .onLongPressGesture(
            minimumDuration: .infinity,     // perform은 사용하지 않음
            maximumDistance: .infinity,
            pressing: { pressing in
                // 눌림 상태(pressing)를 반영
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressing = pressing
                }
                // 손을 떼는 순간 action() 호출
                if !pressing {
                    action()
                }
            },
            perform: { /* 비워둠 */ }
        )
    }
}


