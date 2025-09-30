//
//  AdaptiveScrollView.swift
//  Plantory
//
//  Created by 주민영 on 9/14/25.
//

import SwiftUI

/// 스크롤 위치에 따라 상단/하단 패딩을 조절하는 커스텀 ScrollView
struct AdaptiveScrollView<Content: View>: View {
    @ViewBuilder let content: Content
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    
    @State private var topOffset: CGFloat = 0
    @State private var bottomOffset: CGFloat = 0
    
    init(
        topPadding: CGFloat = 16,
        bottomPadding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            // 스크롤 맨 위 감지
            GeometryReader { geo in
                Color.clear
                    .preference(key: TopOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).minY)
            }
            .frame(height: 0)
            
            VStack(spacing: 16) {
                content
            }
            // topOffset이 양수 → 맨 위 도달
            // bottomOffset이 음수 → 맨 아래 도달
            .padding(.top, topOffset >= 0 ? topPadding : 0)
            .padding(.bottom, bottomOffset > 0 ? bottomPadding : 0)
            
            // 스크롤 맨 아래 감지
            GeometryReader { geo in
                Color.clear
                    .preference(key: BottomOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).maxY)
            }
            .frame(height: 0)
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(TopOffsetKey.self) { value in
            // 스크롤 맨 위면 minY가 0, 아래로 내리면 음수로 내려감
            topOffset = value
        }
        .onPreferenceChange(BottomOffsetKey.self) { value in
            // 뷰포트의 bottom과 ScrollView content bottom 차이를 감지
            let screenHeight = UIScreen.main.bounds.height
            bottomOffset = screenHeight - value
        }
    }
}

/// 스크롤 오프셋 감지를 위한 PreferenceKey
private struct TopOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct BottomOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
