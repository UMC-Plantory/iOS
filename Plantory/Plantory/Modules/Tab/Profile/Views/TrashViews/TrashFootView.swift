//
//  TrashFootView.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI

/// 하단 복원/삭제 버튼 뷰
struct TrashFootView: View {
    @Binding var isEditing: Bool
    let isEmpty: Bool
    let onRestore: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack {
            if isEditing {
                HStack {
                    MainSmallButton(
                        text: "복원하기",
                        isDisabled: isEmpty,
                        action: onRestore
                    )
                    Spacer()
                    MainSmallButton(
                        text: "삭제",
                        isDisabled: isEmpty,
                        action: onDelete
                    )
                }

            } else {
                HStack {
                    Text("휴지통에 있는 항목은 이동된 날짜로부터 30일 뒤 영구삭제 됩니다.")
                        .font(.pretendardLight(12))
                        .foregroundColor(.gray08Dynamic)
                        .padding(.vertical, 11)
                }
            }
        }
        .padding(.bottom, 10)
    }
}
