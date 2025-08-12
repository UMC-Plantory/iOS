//
//  MainBigButton.swift
//  Plantory
//
//  Created by 주민영 on 7/10/25.
//

import SwiftUI

struct MainBigButton: View {
    let text: String
    let action: () -> Void
    var isDisabled: Bool = false

    /// 커스텀 버튼 생성자
    /// - Parameters:
    ///   - text: 버튼 안에 표시될 텍스트
    ///   - isDisabled: 버튼 비활성화 상태 여부
    ///   - action: 버튼 클릭 시 실행할 동작
    init(
        text: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.pretendardSemiBold(24))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .buttonStyle(MainButtonStyle(isDisabled: isDisabled))
        .disabled(isDisabled)
    }
}

#Preview {
    MainBigButton(
        text: "적용하기",
        isDisabled: false,
        action: {
            print("적용하기")
        }
    )
}
