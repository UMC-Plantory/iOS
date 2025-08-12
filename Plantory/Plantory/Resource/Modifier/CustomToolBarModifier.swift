//
//  CustomToolBarModifier.swift
//  Plantory
//
//  Created by 주민영 on 7/10/25.
//

import Foundation
import SwiftUI

/// 재사용 가능한 커스텀 툴바 Modifier
/// - 뒤로가기 버튼 (leading), 중앙 타이틀 (principal), 오른쪽 버튼 (trailing)을 포함함
import SwiftUI

struct CustomModifier<Leading: View, Trailing: View>: ViewModifier {
    let title: String?
    let leading: Leading?
    let trailing: Trailing?
    let topPadding: CGFloat = 17
    let bottomPadding: CGFloat = 17

    func body(content: Content) -> some View {
        content
            .toolbar {
                if let leading = leading {
                    ToolbarItem(placement: .topBarLeading) {
                        leading
                            .padding(.top, topPadding)
                            .padding(.bottom, bottomPadding)
                    }
                }

                if let title = title {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.pretendardSemiBold(20))
                            .padding(.top, topPadding)
                            .padding(.bottom, bottomPadding)
                    }
                }

                if let trailing = trailing {
                    ToolbarItem(placement: .topBarTrailing) {
                        trailing
                            .padding(.top, topPadding)
                            .padding(.bottom, bottomPadding)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    /// 커스텀 네비게이션 툴바를 뷰에 적용하는 Modifier
    ///
    /// - Parameters:
    ///   - title: 툴바 중앙 타이틀 (선택 사항)
    ///   - leading: 왼쪽에 표시할 뷰
    ///   - trailing: 오른쪽에 표시할 뷰
    func customNavigation<Leading: View, Trailing: View>(
        title: String? = nil,
        leading: Leading? = Spacer(),
        trailing: Trailing? = Spacer()
    ) -> some View {
        self.modifier(CustomModifier(title: title, leading: leading, trailing: trailing))
    }
}
