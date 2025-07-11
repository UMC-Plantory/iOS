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
struct CustomToolBarModifier: ViewModifier {
    
    let title: String?
    let leadingIsImage: Bool?
    let leadingContent: String?
    let leadingAction: (() -> Void)?
    let trailingIsImage: Bool?
    let trailingContent: String?
    let trailingAction: (() -> Void)?
    
    let bottomPadding: CGFloat = 17
    let topPadding: CGFloat = 17
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                // 왼쪽: 뒤로가기
                if let leadingIsImage = leadingIsImage, let leadingContent = leadingContent, let leadingAction = leadingAction {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: leadingAction) {
                            if leadingIsImage {
                                Image(leadingContent)
                                    .fixedSize()
                            } else {
                                Text(leadingContent)
                                    .foregroundStyle(.green07)
                                    .font(.pretendardRegular(16))
                            }
                        }
                        .padding(.bottom, bottomPadding)
                        .padding(.top, topPadding)
                    }
                }
                
                // 가운데 타이틀
                if let title = title {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.pretendardSemiBold(20))
                            .foregroundStyle(.black01)
                            .padding(.bottom, bottomPadding)
                            .padding(.top, topPadding)
                    }
                }
                
                // 오른쪽 버튼
                if let trailingIsImage = trailingIsImage, let trailingContent = trailingContent, let action = trailingAction {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: action) {
                            if trailingIsImage {
                                Image(trailingContent)
                                    .fixedSize()
                            } else {
                                Text(trailingContent)
                                    .foregroundStyle(.green07)
                                    .font(.pretendardRegular(16))
                            }
                            
                        }
                        .padding(.bottom, bottomPadding)
                        .padding(.top, topPadding)
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
    ///   - leadingIsImage: 왼쪽 버튼이 이미지인지 (선택 사항)
    ///   - leadingContent: 왼쪽 버튼에 표시할 이미지 이름/Text 글씨 (선택 사항)
    ///   - leadingAction: 왼쪽 버튼을 눌렀을 때 실행할 액션 (선택 사항)
    ///   - trailingIsImage: 오른쪽 버튼에 표시할 이미지 이름/Text 글씨 (선택 사항)
    ///   - trailingContent: 오른쪽 버튼에 표시할 이미지 이름/Text 글씨 (선택 사항)
    ///   - trailingAction: 오른쪽 버튼 터치 시 실행될 액션 (선택 사항)
    func customNavigation(
        title: String? = nil,
        leadingIsImage: Bool = true,
        leadingContent: String? = nil,
        leadingAction: (() -> Void)? = nil,
        trailingIsImage: Bool = true,
        trailingContent: String? = nil,
        trailingAction: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            CustomToolBarModifier(
                title: title,
                leadingIsImage: leadingIsImage,
                leadingContent: leadingContent,
                leadingAction: leadingAction,
                trailingIsImage: trailingIsImage,
                trailingContent: trailingContent,
                trailingAction: trailingAction
            )
        )
    }
}
