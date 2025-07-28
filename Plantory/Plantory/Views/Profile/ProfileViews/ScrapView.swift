//
//  ScrapView.swift
//  Plantory
//
//  Created by 이효주 on 7/8/25.
//

import SwiftUI

struct ScrapView: View {
    var body: some View {
        EmptyView(mainText: "스크랩 한 일기가 없어요", subText: "오래 보관하고 싶은 일기를 스크랩 해보세요!", buttonTitle: "리스트 페이지로 이동하기", buttonAction: { // 리스트 페이지로 이동 처리
        })
    }
}

#Preview {
    ScrapView()
}
