//
//  CompletionView.swift
//  Plantory
//
//  Created by 박정환 on 7/21/25.
//

import SwiftUI
import Foundation

struct FlowerCompleteView: View {
    @EnvironmentObject var container: DIContainer
    @State var viewModel: TerrariumViewModel
    var onGoToGarden: (() -> Void)? = nil
    var onGoHome: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Image(flowerImageName)
                    .resizable()
                    .frame(width: 286, height: 286)
                    .padding(.bottom, 16)
                
                middleContent
                    .padding(.bottom, 16)
                
                lowContent
                
                Spacer()
                
                MainBigButton(
                    text: "나의 정원 가기",
                    isDisabled: false,
                    action: {
                        onGoToGarden?()
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
            .background(
                Color.white.ignoresSafeArea()
            )
            .customNavigation(
                trailing:
                    Button(action: {
                        onGoHome?()
                    }, label: {
                        Image("Home")
                            .foregroundStyle(.gray10)
                            .fixedSize()
                    })
            )
        }
    }
}

// MARK: - Private helpers & subviews

private extension FlowerCompleteView {
    // Flower emotion mapping (영문 코드 → 한글 레이블)
    var flowerEmotionKorean: String? {
        let code = viewModel.lastWateringResult?.flowerEmotion?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else { return nil }
        switch code.uppercased() {
        case "HAPPY":   return "기쁨"
        case "AMAZING": return "놀람"
        case "SAD":     return "슬픔"
        case "SOSO":    return "그럭저럭"
        case "ANGRY":   return "화남"
        default:        return code // 매핑 없으면 원문 표시
        }
    }

    // 표시에 사용할 감정 통계 아이템
    struct EmotionStat: Identifiable {
        let id = UUID()
        let imageName: String
        let count: Int
    }

    // 감정 리스트를 카드 표시용 배열로 변환
    var emotionStats: [EmotionStat] {
        // 원하는 표시 순서가 있으면 정렬
        let order: [String] = ["HAPPY", "AMAZING", "SOSO", "SAD", "ANGRY"]
        let keyed = (viewModel.lastWateringResult?.emotionList ?? [:]).map { (key: $0.key.uppercased(), value: $0.value) }
        let sorted = keyed.sorted { lhs, rhs in
            let li = order.firstIndex(of: lhs.key) ?? Int.max
            let ri = order.firstIndex(of: rhs.key) ?? Int.max
            return li < ri
        }
        return sorted.map { EmotionStat(imageName: $0.key, count: $0.value) }
    }

    // Flower image name mapping (한글 이름 → 에셋 이름)
    var flowerImageName: String {
        switch viewModel.lastWateringResult?.flowerName {
        case "장미":
            return "Rose"
        case "민들레":
            return "Dandelion"
        case "해바라기":
            return "Sunflower"
        case "개나리":
            return "Forsythia"
        case "물망초":
            return "ForgetMeNot"
        case let name?:
            return name // 원본 이름 반환 (영문 asset이 있을 경우)
        default:
            return "Rose"
        }
    }

    // MARK: Subviews

    var middleContent: some View {
        VStack(spacing: 4) {
            (
                Text("축하합니다! \(viewModel.lastWateringResult?.nickname ?? "00")님이 ")
                    .foregroundColor(.black)
                    .font(.pretendardSemiBold(16)) +
                Text(viewModel.lastWateringResult?.flowerName ?? "식물")
                    .foregroundColor(.red)
                    .font(.pretendardSemiBold(16)) +
                Text("를 피워냈어요!")
                    .foregroundColor(.black)
                    .font(.pretendardSemiBold(16))
            )
            if let emo = flowerEmotionKorean {
                Text("이번 식물은 ‘\(emo)’이 가장 많아요.")
                    .foregroundColor(.black)
                    .font(.pretendardSemiBold(16))
            }
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

    var lowContent: some View {
        HStack(spacing: 8) {
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
}

#Preview {
    FlowerCompleteView(
        viewModel: TerrariumViewModel(container: DIContainer()),
        onGoToGarden: {},
        onGoHome: {}
    )
    .environmentObject(DIContainer())
}
