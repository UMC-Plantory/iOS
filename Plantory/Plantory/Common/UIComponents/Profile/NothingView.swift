//
//  EmptyView.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import SwiftUI

/// 사용예시
/// EmptyView(mainText: "스크랩 한 일기가 없어요",
///  subText: "오래 보관하고 싶은 일기를 스크랩 해보세요!",
///  buttonTitle: "리스트 페이지로 이동하기",
///  buttonAction: {})
struct NothingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let mainText: String
    let subText: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    init(
        mainText: String,
        subText: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.mainText     = mainText
        self.subText      = subText
        self.buttonTitle  = buttonTitle
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Plant")
                .resizable()
                .frame(width: 151, height: 93)
            VStack {
                Text(mainText)
                    .font(.pretendardSemiBold(16))
                    .foregroundStyle(.gray10Dynamic)
                Spacer().frame(height: 5)
                Text(subText)
                    .font(.pretendardMedium(14))
                    .foregroundStyle(.gray08Dynamic)
            }
            
            if let title = buttonTitle,
               let action = buttonAction {
                Button(action: action) {
                    Text(title)
                        .font(.pretendardRegular(14))
                        .foregroundStyle(.green06)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(colorScheme == .light ? .clear : .yellow01)
                                .stroke(.green06, lineWidth: 1)
                        )
                }
            }
        }
    }
}

#Preview {
    NothingView(mainText: "스크랩 한 일기가 없어요", subText: "오래 보관하고 싶은 일기를 스크랩 해보세요!", buttonTitle: "리스트 페이지로 이동하기", buttonAction: {})
}
