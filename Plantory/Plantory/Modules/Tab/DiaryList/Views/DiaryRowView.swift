//
//  DiaryRowView.swift
//  Plantory
//
//  Created by 박병선 on 8/9/25.
//  일기 개별 뷰(다이어리 리스트에서) 

import SwiftUI

//DiaryList의 하위뷰로 각각의 일기를 보여주는 View입니다. 
struct DiaryRow: View {
    let entry: DiaryFilterSummary

    var body: some View {
        ZStack(alignment: .leading) {
            // 배경 카드 (회색)
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray02Dynamic)
                .frame(maxWidth: .infinity)
                .frame(height: 132)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)

            // 흰색 카드 + 내용
            RoundedRectangle(cornerRadius: 10)
                .fill(.diaryrowbackground)
                .frame(maxWidth: .infinity)
                .frame(height: 132)
                .background(
                    Rectangle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 6)
                        .blur(radius: 6)
                        .offset(x: 10),
                    alignment: .trailing
                )
                .overlay(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 즐겨찾기 아이콘
                        Image(entry.status == "SCRAP" ? "star_green" : "star_gray")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.top, 4)
                        
                        // 제목
                        Text(entry.title)
                            .font(.pretendardSemiBold(18))
                            .foregroundColor(.black01Dynamic)
                            .padding(.top, 4)
                        
                        // 내용
                        Text(entry.content)
                            .font(.pretendardRegular(14))
                            .foregroundColor(.gray08)
                            .padding(.top, 8)
                            .lineLimit(1)
                        
                        // 감정 텍스트
                        Text(entry.emotion.displayName)
                            .font(.pretendardRegular(12))
                            .foregroundColor(.green04)
                            .padding(.top, 24)
                    }
                    .padding(.horizontal, 11)
                    .frame(width: 252, alignment: .leading)
                }

            // 날짜와 감정 책갈피
            VStack(alignment: .trailing, spacing: 6) {
                
                ZStack(alignment: .trailing) {
                    // 배경: 연한 초록(왼쪽 32pt) + 진한 초록(오른쪽 41pt)
                    HStack(spacing: 0) {
                        Color(.green04).opacity(0.3) // 왼쪽 흐린 초록
                            .frame(width: 32)

                        Color(.green04) // 오른쪽 진한 초록
                            .frame(width: 41)
                    }
                    .frame(width: 73, height: 31)
                    .cornerRadius(5)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 2, y: 2)

                    // 날짜 텍스트 (오른쪽 정렬)
                    Text(formatToMonthDay(entry.diaryDate))
                        .font(.pretendardRegular(14))
                        .foregroundColor(Color.white)
                        .padding(.trailing, 4) // 텍스트 오른쪽 여백
                }
              
                RoundedCorner(radius: 5, corners: [.topRight, .bottomRight])
                    .fill(entry.emotion.color)
                    .frame(width: 24, height: 23)
                    .offset(x: -15)
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
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

#Preview {
    DiaryRow(entry:
        DiaryFilterSummary(
            diaryId: 1,
            diaryDate: "2025-09-27",
            title: "첫 번째 일기",
            status: "completed",
            emotion: .HAPPY,
            content: "오늘은 정말 즐거운 하루였다. 친구들과 함께 점심을 먹고 산책도 다녀왔다."
        )
    )
}
