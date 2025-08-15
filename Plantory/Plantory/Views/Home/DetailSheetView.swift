//
//  DetailSheetView.swift
//  Plantory
//
//  Created by 김지우 on 8/6/25.
//

import SwiftUI

struct DetailSheetView: View {
    let date: Date
    let entry: DiaryEntryData?

    @EnvironmentObject var container: DIContainer

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df
    }()

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 8)

            DateTextHeader

            ZStack {
                // 미래 날짜 경고
                if date > Calendar.current.startOfDay(for: Date()) {
                    VStack {
                        Spacer()
                        Text("미래의 일기는 작성할 수 없어요!")
                            .font(.pretendardRegular(14))
                            .foregroundColor(.gray11)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }

                // 작성된 일기 있는 경우
                } else if let entry = entry {
                    Button {
                        // 상세 이동 (필요 시 라우팅 추가)
                    } label: {
                        HStack {
                            // 제목
                            Text(entry.text)
                                .font(.pretendardRegular(14))
                                .foregroundColor(.black)
                                .lineLimit(1)

                            Spacer().frame(width: 4)

                            // 감정 텍스트
                            Text(entry.emotiontext)
                                .font(.pretendardRegular(12))
                                .foregroundColor(.gray08)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(entry.emotion.EmotionColor)
                                .frame(width: 340, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                    }
                    .padding(.bottom, 24)

                // 작성된 일기 없는 경우
                } else {
                    VStack {
                        Spacer()
                        Text("작성된 일기가 없어요!")
                            .font(.pretendardRegular(14))
                            .foregroundColor(.gray11)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 24)
        .frame(height: 264)
    }

    private var DateTextHeader: some View {
        HStack {
            Text("\(date, formatter: dateFormatter)")
                .font(.pretendardRegular(20))
                .foregroundColor(.black01)
            Spacer()
            if date <= Calendar.current.startOfDay(for: Date()) {
                Button {
                    // 연관값 필요: .addDiary(date:)
                    container.navigationRouter.push(.addDiary)
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.green05)
                }
            }
        }
    }
}
