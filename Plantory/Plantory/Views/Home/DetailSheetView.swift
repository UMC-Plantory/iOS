//
//  DetailSheetView.swift
//  Plantory
//
//  Created by 김지우 on 8/6/25.
//


import SwiftUI
import Observation

struct DetailSheetView: View {
    @Bindable var viewModel: HomeViewModel
    let date: Date
    var onTapAdd: (() -> Void)? = nil

    @EnvironmentObject var container: DIContainer
    @Environment(\.dismiss) private var dismiss

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df
    }()

    private var isFuture: Bool {
        let cal = Calendar.current
        return cal.startOfDay(for: date) > cal.startOfDay(for: Date())
    }

    var body: some View {
        ZStack {
            (isFuture ? Color.gray04 : Color.white01).ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer().frame(height: 8)
                HStack {
                    Text("\(date, formatter: dateFormatter)")
                        .font(.pretendardRegular(20))
                        .foregroundColor(.black01)
                    Spacer()
                    if !isFuture {
                        Button {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                if let onTapAdd { onTapAdd() }
                                else { container.navigationRouter.push(.addDiary) }
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                                .foregroundColor(.green05)
                        }
                    }
                }
                ZStack {
                    if isFuture {
                        CenterMessage("미래의 일기는 작성할 수 없어요!")
                    } else if viewModel.isLoadingDiary {
                        ProgressView().tint(.gray)
                    } else if viewModel.noDiaryForSelectedDate {
                        CenterMessage("작성된 일기가 없어요!")
                    } else if let summary = viewModel.diarySummary {
                        Button {
                            // TODO: 상세(편집)로 라우팅
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
