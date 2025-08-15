//
//  DetailSheetView.swift
//  Plantory
//
//  Created by 김지우 on 8/6/25.
//

import SwiftUI
import Observation

struct DetailSheetView: View {
    //바인딩 주입
    @Bindable var viewModel: HomeViewModel
    let date: Date

    //지정 형식으로 날짜를 포맷
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df
    }()

    //날짜 현재/미래 여부(미래 일기는 작성 불가능)
    private var isFuture: Bool {
        let cal = Calendar.current
        return cal.startOfDay(for: date) > cal.startOfDay(for: Date())
    }

    var body: some View {
        ZStack {
            (isFuture ? Color.gray04 : Color.white01).ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer().frame(height: 8)

                // 헤더
                HStack {
                    Text("\(date, formatter: dateFormatter)")
                        .font(.pretendardRegular(20))
                        .foregroundColor(.black01)
                    Spacer()
                    if !isFuture {
                        Button {
                            // TODO: 작성 화면 이동 훅업
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                                .foregroundColor(.green05)
                        }
                    }
                }

                // 본문
                ZStack {
                    if isFuture {
                        CenterMessage("미래의 일기는 작성할 수 없어요!")
                    } else if viewModel.isLoadingDiary {
                        ProgressView().tint(.gray)
                    } else if viewModel.noDiaryForSelectedDate {
                        CenterMessage("작성된 일기가 없어요!")
                    } else if let summary = viewModel.diarySummary {
                        Button {
                            // TODO: 일기 상세 이동 훅업
                        } label: {
                            HStack {
                                Text(summary.title)
                                    .font(.pretendardRegular(14))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                Spacer().frame(width: 4)
                                Text("•\(summary.emotion)")
                                    .font(.pretendardRegular(12))
                                    .foregroundColor(.gray08)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(CalendarView.emotionColor(for: summary.emotion))
                                    .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                    .frame(width: 340, height: 56)
                            )
                        }
                        .padding(.bottom, 24)
                    } else {
                        // 선택은 했지만 아직 데이터가 안 온 순간 등
                        ProgressView().tint(.gray)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 24)
            .frame(height: 264)
        }
        .presentationDetents([.height(264)])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Helper
    @ViewBuilder
    private func CenterMessage(_ text: String) -> some View {
        VStack { Spacer()
            Text(text)
                .font(.pretendardRegular(14))
                .foregroundColor(.gray11)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}
