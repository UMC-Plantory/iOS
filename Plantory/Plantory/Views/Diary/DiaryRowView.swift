//
//  DiaryRowView.swift
//  Plantory
//
//  Created by 박병선 on 8/9/25.
//  일기 개별 뷰(다이어리 리스트에서) 

import SwiftUI

struct DiaryRow: View {
    let entry: DiaryEntry

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
                        Image(entry.isFavorite ? "star_green" : "star_gray")
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
                        Text(entry.emotion.rawValue)
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
                        Text(dateFormatter.string(from: entry.date))
                            .font(.pretendardRegular(14))
                            .foregroundColor(Color("white01"))
                            .padding(.trailing, 3) // 텍스트 오른쪽 여백
                    }

                .padding(.top, -4)
              
                RoundedCorner(radius: 5, corners: [.topRight, .bottomRight])
                    .fill(entry.emotion.color)
                    .frame(width: 24, height: 23)
                    .offset(x: -15)
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(maxHeight: .infinity)
            .padding(.top, -4)
            .padding(.trailing, 30)
        }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MM.dd"
        return f
    }
}
