//
//  DiarySearchRow.swift
//  Plantory
//
//  Created by 박병선 on 8/19/25.
//

import SwiftUI

//DiaryList의 하위뷰로 각각의 일기를 보여주는 View입니다.
struct DiarySearchRow: View {
    let entry: DiarySummary

    var body: some View {
        ZStack(alignment: .leading) {
            // 배경 카드 (회색)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("gray02"))
                .frame(width: 358, height: 132)

            // 흰색 카드 + 내용
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("white01"))
                .frame(width: 300, height: 132)
                .overlay(
                    VStack(alignment: .leading, spacing: 0) {
                        // 즐겨찾기 아이콘
                        Image(entry.status == "SCRAP" ? "star_green" : "star_gray")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.top, -4)
                            

                        // 제목
                        Text(entry.title)
                            .font(.pretendardSemiBold(18))
                            .foregroundColor(Color("black01"))
                            .padding(.top, 8)

                        // 내용
                        Text(entry.content)
                            .font(.subheadline)
                            .foregroundColor(Color("gray08"))
                            .padding(.top,4)
                        //.lineLimit(1)

                        // 감정 텍스트
                        Text(Emotion(apiString: entry.emotion).rawValue)
                            .font(.pretendardRegular(12))
                            .foregroundColor(Color("green04"))
                            .padding(.top, 24)
                    }
                    .padding(.leading, 11)
                 
                )

            // 날짜와 감정 책갈피
            VStack(alignment: .trailing, spacing: 6) {
                
                ZStack(alignment: .trailing) {
                        // 배경: 연한 초록(왼쪽 32pt) + 진한 초록(오른쪽 41pt)
                        HStack(spacing: 0) {
                            Color("green04").opacity(0.3) // 왼쪽 흐린 초록
                                .frame(width: 32)

                            Color("green04") // 오른쪽 진한 초록
                                .frame(width: 41)
                        }
                        .frame(width: 73, height: 31)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 2, y: 2)

                        // 날짜 텍스트 (오른쪽 정렬)
                        Text(entry.diaryDate)
                            .font(.pretendardRegular(14))
                            .foregroundColor(Color("white01"))
                            .padding(.trailing, 3) // 텍스트 오른쪽 여백
                    }

                .padding(.top, -4)
              
                RoundedCorner(radius: 5, corners: [.topRight, .bottomRight])
                    .fill(Emotion(apiString: entry.emotion).color)
                    .frame(width: 24, height: 23)
                    .offset(x: -15)
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(maxHeight: .infinity)
            .padding(.top, -4)
            .padding(.trailing, 30)
        }
    }
    
    private func formatToMonthDay(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // 안정성 위해 설정

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM.dd"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString // 변환 실패 시 원본 반환
        }
    }

}

// MARK: - Preview
struct DiarySearchRow_Previews: PreviewProvider {
    static var previews: some View {
        DiarySearchRow(
            entry: DiarySummary(
                diaryId: 1,
                diaryDate: "2025-05-19",
                title: "행복했던 하루",
                status: "NORMAL",   // "SCRAP"이면 초록별 표시
                emotion: "HAPPY",
                content: "오늘은 친구랑 카페에서 즐거운 시간을 보냈다."
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}

