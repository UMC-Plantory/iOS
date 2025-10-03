//
//  MainMiddleButton.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import SwiftUI

struct MainMiddleButton: View {
    let text: String
    let action: () -> Void
    var isDisabled: Bool = false
    var fontSize: CGFloat = 18

    /// 커스텀 버튼 생성자
    /// - Parameters:
    ///   - text: 버튼 안에 표시될 텍스트
    ///   - isDisabled: 버튼 비활성화 상태 여부
    ///   - action: 버튼 클릭 시 실행할 동작
    init(
        text: String,
        isDisabled: Bool = false,
        fontSize: CGFloat = 18,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.isDisabled = isDisabled
        self.fontSize = fontSize
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.pretendardRegular(fontSize))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .buttonStyle(MainButtonStyle(isDisabled: isDisabled))
        .disabled(isDisabled)
    }
}

#Preview {
    MainMiddleButton(text: "적용하기", isDisabled: false, action: {
        print("hello")
    })
}

