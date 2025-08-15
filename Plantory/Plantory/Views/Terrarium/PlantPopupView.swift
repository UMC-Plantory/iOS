//
//  PlantPopupView.swift
//  Plantory
//
//  Created by 박정환 on 7/16/25.
//

import SwiftUI

struct PlantPopupView: View {
    @State var viewModel: PlantPopupViewModel
    var onClose: () -> Void

    var body: some View {
        if viewModel.isPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    HStack {
                        Text(viewModel.flowerNameText)
                            .font(.pretendardSemiBold(20))
                            .padding(.leading, 149)
                        Spacer()
                        Button(action: {
                            onClose()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color("gray04"))
                                .font(.system(size: 24))
                        }
                        .padding(.trailing, 12)
                    }
                    .padding(.top, 12)

                    HStack(alignment: .center, spacing: 8) {
                        Image(imageName(for: viewModel.flowerNameText))
                            .resizable()
                            .frame(width: 120, height: 120)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .center, spacing: 12) {
                                SectionLabel(text: "최다 감정")
                                Text(viewModel.feelingText)
                                    .font(.pretendardRegular(16))
                            }
                            HStack(alignment: .center, spacing: 12) {
                                SectionLabel(text: "생성일")
                                Text(viewModel.birthDateText)
                                    .font(.pretendardRegular(16))
                            }
                            HStack(alignment: .center, spacing: 12) {
                                SectionLabel(text: "완성일")
                                Text(viewModel.completeDateText)
                                    .font(.pretendardRegular(16))
                            }
                        }
                    }
                    .padding(.top, 38)
                    .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel(text: "사용된 일기")
                            DiaryInfo(items: viewModel.usedDateTexts)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel(text: "단계 진입일")
                            StageInfo(items: viewModel.stageTexts.map { "\($0.0) \($0.1)" })
                        }
                    }
                    .frame(width: 278)
                    .clipped()

                    Spacer()
                }
                .frame(width: 334, height: 444)
                .background(
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color("green01"))
                            .frame(width: 308, height: 361)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color("green04"), lineWidth: 1)
                            )
                            .position(x: geometry.size.width / 2, y: 66 + 361 / 2)
                    }
                )
                .background(Color.white)
                .cornerRadius(5)
            }
        }
    }
    
    //섹션 라벨
    struct SectionLabel: View {
        var text: String

        var body: some View {
            Text(text)
                .font(.pretendardSemiBold(14))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color("green04"))
                )
        }
    }

    //사용된 일기
    struct DiaryInfo: View {
        var items: [String]

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Button(action: {
                            // action
                        }) {
                            HStack(spacing: 8) {
                                Text(item)
                                    .foregroundColor(Color("green08"))
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("green06"))
                            }
                            .font(.pretendardRegular(14))
                            .frame(width: 66, height: 29)
                            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color("green06"), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    //단계 진입일
    struct StageInfo: View {
        var items: [String]

        var body: some View {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    StageInfo.StageChip(item: item)
                }
            }
        }
        
        struct StageChip: View {
            let item: String
            private var parts: [Substring] { item.split(separator: " ") }
            private var stage: String { parts.first.map(String.init) ?? "" }
            private var date: String { parts.dropFirst().first.map(String.init) ?? "" }

            var body: some View {
                HStack(spacing: 4) {
                    Text(stage)
                        .foregroundColor(Color("green08"))
                    Text(date)
                        .foregroundColor(Color("green06"))
                }
                .font(.pretendardRegular(14))
                .frame(height: 29)
                .padding(.horizontal, 8)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color("green06"), lineWidth: 1))
            }
        }
    }
}


private extension PlantPopupView {
    /// Flower image name mapping (한글 이름 → 에셋 이름)
    func imageName(for flowerName: String) -> String {
        switch flowerName {
        case "장미": return "Rose"
        case "민들레": return "Dandelion"
        case "해바라기": return "Sunflower"
        case "개나리": return "Forsythia"
        case "물망초": return "ForgetMeNot"
        default: return "DefaultPlant"
        }
    }
}



