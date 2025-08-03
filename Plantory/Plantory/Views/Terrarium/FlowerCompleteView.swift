//
//  CompletionView.swift
//  Plantory
//
//  Created by 박정환 on 7/21/25.
//

import SwiftUI
import Foundation

struct FlowerCompleteView: View {
    var body: some View {
        NavigationStack{
            VStack {
                Spacer()
                
                Image("Rose")
                    .resizable()
                    .frame(width: 286, height: 286)
                    .padding(.bottom, 16)
                
                middleContent
                    .padding(.bottom, 16)
                
                lowContent
                
                Spacer()
                
                MainSmallButton(
                    text: "나의 정원 가기",
                    isDisabled: false,
                    action: {
                        print("나의 정원 가기")
                    }
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
                .padding(.bottom, 90)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image("PlantBackground")
                    .resizable()
                    .frame(width: 1036, height: 1036)
                    .ignoresSafeArea()
            )
            .customNavigation(
                trailing:
                    Button(action: {
                        print("취소")
                    }, label: {
                        Image("Home")                            .foregroundStyle(.gray10)
                            .fixedSize()
                    })
            )
        }
    }
}


private var middleContent: some View {
    VStack(spacing: 4) {
        (
            Text("축하합니다! 00님이 ")
                .font(.pretendardSemiBold(16)) +
            Text("장미")
                .foregroundColor(.red)
                .font(.pretendardSemiBold(16)) +
            Text("를 피워냈어요!")
                .font(.pretendardSemiBold(16))
        )
        Text("이번 식물은 ‘화남’이 가장 많아요.")
            .font(.pretendardSemiBold(16))
    }
    .multilineTextAlignment(.center)
    .padding(.vertical, 16)
    .padding(.horizontal, 36)
    .background(
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color("yellow04"), lineWidth: 2)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
    )
}

private var lowContent: some View {
    HStack(spacing:8) {
        ForEach(emotionStats) { stat in
            VStack {
                ZStack {
                    GradientBox(width: 48, height: 48, cornerRadius: 4, LightGradient: true)
                        .padding(.top, 4)

                    Image(stat.imageName)
                        .resizable()
                        .frame(width: 23, height: 27)
                }
                Text("\(stat.count)")
                    .font(.pretendardRegular(16))
                    .padding(.bottom, 4)
            }
            .frame(width: 56, height: 80)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color("yellow04"), lineWidth: 1)
            )
        }
    }
}

#Preview {
    FlowerCompleteView()
}
