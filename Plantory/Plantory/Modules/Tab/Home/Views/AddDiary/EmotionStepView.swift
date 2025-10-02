//
//  EmotionStepView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

struct EmotionStepView: View {
    @Bindable var vm: AddDiaryViewModel
    let onSelected: () -> Void

    var body: some View {
        

        Text("오늘의 감정을 선택해주세요")
            .font(.pretendardSemiBold(20))
            .foregroundStyle(.adddiaryfont)
            .padding(.bottom, 20)

        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green04, lineWidth: 1)
                .background(Color.clear)
                .frame(width: 334, height: 234)
            EmotionGrid
        }
        Spacer()
    }

    private var EmotionGrid: some View {
        VStack {
            HStack {
                emotionButton(untapped: .happyUntapped, tapped: .happyTapped, label: "기쁜", value: "HAPPY")
                Spacer().frame(width: 56)
                emotionButton(untapped: .sadUntapped, tapped: .sadTapped, label: "슬픈", value: "SAD")
                Spacer().frame(width: 56)
                emotionButton(untapped: .madUntapped, tapped: .madTapped, label: "화난", value: "ANGRY")
            }
            HStack {
                emotionButton(untapped: .normalUntapped, tapped: .normalTapped, label: "그저그런", value: "SOSO")
                Spacer().frame(width: 56)
                emotionButton(untapped: .surprisedUntapped, tapped: .surprisedTapped, label: "놀란", value: "AMAZING")
            }
        }
    }

    private func emotionButton(untapped: ImageResource,
                               tapped: ImageResource,
                               label: String,
                               value: String) -> some View {
        LongPressEmotionButton(
            untappedImage: untapped,
            tappedImage: tapped,
            label: label
        ) {
            vm.emotion = value
            onSelected()
        }
    }
}

