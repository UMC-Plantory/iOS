//
//  PopUp.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import SwiftUI

/// 공용 확인/취소 팝업 컴포넌트
struct PopUp: View {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    // MARK: Animation properties
    @State private var appearScale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // 제목
                Text(title)
                    .font(.pretendardSemiBold(18))
                
                Spacer().frame(height: 6)
                
                // 메시지
                Text(message)
                    .font(.pretendardRegular(14))
                    .foregroundColor(.gray09)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer().frame(height: 27)
                
                HStack(spacing: 10) {
                    Spacer()
                    
                    // 취소 버튼
                    StrokeSmallButton(
                        text: cancelTitle,
                        action: onCancel
                    )
                    
                    // 확인 버튼
                    MainSmallButton(
                        text: confirmTitle,
                        action: onConfirm
                    )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
            .padding(.horizontal, 25)
            .scaleEffect(appearScale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    appearScale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

struct BlurBackground: View {
    
    // State to animate the blur opacity
    @State private var blurAmount: CGFloat = 0
    
    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea(edges: .all)
            .opacity(blurAmount)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.1)) {
                    blurAmount = 1
                }
            }
    }
}

#Preview {
    PopUp(
        title: "일기를 삭제하시겠습니까?",
        message: "일기 삭제 시, 해당 일기는 영구 삭제됩니다.",
        confirmTitle: "삭제하기",
        cancelTitle: "취소",
        onConfirm: {},
        onCancel: {}
    )
}
