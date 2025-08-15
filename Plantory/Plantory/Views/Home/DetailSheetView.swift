//
//  DetailSheetView.swift
//  Plantory
//
//  Created by 김지우 on 8/6/25.
//

import SwiftUI
import Observation

/// HomeView의 시트 전용 뷰
/// - viewModel: HomeViewModel(@Observable)에서 상태를 읽습니다
/// - date: 시트에 표시할 선택 날짜
/// - onTapAdd: 플러스 버튼 탭 시 호출되는 콜백(라우팅은 외부에서 주입)
struct DetailSheetView: View {
    // 바인딩 주입 (@Observable -> @Bindable)
    @Bindable var viewModel: HomeViewModel
    let date: Date
    var onTapAdd: (() -> Void)? = nil

    @EnvironmentObject var container: DIContainer

    // 날짜 포맷
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df
    }()

    // 미래 날짜 여부
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
                            onTapAdd?() // 라우팅은 외부에서
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
                            // TODO: 일기 상세 이동 훅업 (필요 시 외부 콜백 추가)
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
                        // 선택은 했지만 아직 값이 없는 잠깐의 순간
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
        VStack {
            Spacer()
            Text(text)
                .font(.pretendardRegular(14))
                .foregroundColor(.gray11)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}
