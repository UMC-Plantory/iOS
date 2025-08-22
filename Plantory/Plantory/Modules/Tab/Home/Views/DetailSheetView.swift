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
/// - onTapAdd: 플러스 버튼 탭 시 호출되는 콜백(없으면 내부에서 라우팅)
struct DetailSheetView: View {
    // 바인딩 주입 (@Observable -> @Bindable)
    @Bindable var viewModel: HomeViewModel
    let date: Date
    var onTapAdd: (() -> Void)? = nil

    @EnvironmentObject var container: DIContainer
    @Environment(\.dismiss) private var dismiss

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

    /// + 버튼 노출 조건: 미래X, 로딩X, 요약없음 && "일기 없음" 상태일 때
    private var showPlus: Bool {
        guard !isFuture else { return false }
        if viewModel.isLoadingDiary { return false }
        if viewModel.diarySummary != nil { return false }
        return viewModel.noDiaryForSelectedDate
    }

    var body: some View {
        // 배경색: 미래는 gray07, 그 외엔 white01
        let sheetBackground = isFuture ? Color.gray07 : Color.white01

        ZStack {
            sheetBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer().frame(height: 8)

                // 헤더
                HStack {
                    Text("\(date, formatter: dateFormatter)")
                        .font(.pretendardRegular(20))
                        .foregroundColor(.black01)
                    Spacer()

                    if showPlus {
                        Button {
                            // 시트 닫기
                            dismiss()
                            // 닫힘 직후, 선택 날짜로 작성 화면 이동
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if let onTapAdd {
                                    onTapAdd()
                                } else {
                                    // 선택한 날짜를 전달하는 라우트 사용
                                    container.navigationRouter.push(.addDiary(date: date))
                                }
                            }
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
                        // 요약이 있을 때: 상세로 이동
                        Button {
                            dismiss()
                            container.navigationRouter.push(.diaryDetail(diaryId: summary.diaryId))
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
                            .frame(width: 340, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(CalendarView.emotionColor(for: summary.emotion))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                            )
                        }
                        .padding(.bottom, 24)
                    } else {
                        // 선택은 했지만 아직 값이 반영되기 전
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
