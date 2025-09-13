//
//  PopUpModifier.swift
//  Plantory
//
//  Created by 주민영 on 9/11/25.
//

import SwiftUI

struct PopUpModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                ZStack {
                    // 반투명 배경
                    BlurBackground()
                        .onTapGesture {
                            withAnimation { isPresented = false }
                        }
                    
                    // 팝업 본문
                    PopUp(
                        title: title,
                        message: message,
                        confirmTitle: confirmTitle,
                        cancelTitle: cancelTitle,
                        onConfirm: {
                            onConfirm()
                            withAnimation { isPresented = false }
                        },
                        onCancel: {
                            onCancel()
                            withAnimation { isPresented = false }
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                }
                .zIndex(99)
            }
        }
    }
}

extension View {
    func popup(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        onConfirm: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        self.modifier(PopUpModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            onConfirm: onConfirm,
            onCancel: onCancel
        ))
    }
}
