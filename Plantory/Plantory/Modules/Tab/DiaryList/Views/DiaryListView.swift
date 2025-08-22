//
//  DiaryView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

// 일기 리스트페이지 입니다.
struct DiaryListView: View {
    @EnvironmentObject var container: DIContainer
    
    @StateObject private var viewModel: DiaryListViewModel
    
    @State var isFilterSheetPresented: Bool = false

    init(
        container: DIContainer
    ) {
        _viewModel = StateObject(
           wrappedValue: DiaryListViewModel(container: container)
        )
    }

    var body: some View {
        ZStack {
            Color("brown01").ignoresSafeArea()

            VStack(spacing: 20) {
                DiaryHeaderView(
                    onSearchTap: {
                        container.navigationRouter.push(.diarySearch)
                    }
                )

                Rectangle()
                    .fill(Color.gray04)
                    .frame(height: 4)
                    .padding(.bottom, 12)
                    .padding(.horizontal, -18)

                DiaryMonthSectionView(isFilterSheetPresented: $isFilterSheetPresented)

                DiaryListContent
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            DiaryFilterView(viewModel: viewModel)
        }
        .task {
            viewModel.diaries = []
            viewModel.hasNext = true
            viewModel.cursor = nil
            await viewModel.fetchFilteredDiaries()
        }
        .toastView(toast: $viewModel.toast)
    }
    
    // 스크롤 리스트
    private var DiaryListContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.diaries) { diary in
                    Button {
                        container.navigationRouter.push(.diaryDetail(diaryId: diary.diaryId))
                    } label: {
                        DiaryRow(entry: diary)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if diary.id == viewModel.diaries.last?.id {
                            Task {
                                await viewModel.fetchFilteredDiaries()
                            }
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView().padding()
                }
            }
        }
    }
}

// 상단 헤더
struct DiaryHeaderView: View {
    var onSearchTap: () -> Void = {}
    var onMoreTap: () -> Void = {}

    var body: some View {
        HStack {
            Text("일기목록")
                .font(.pretendardSemiBold(20))
                .foregroundColor(.black01)

            Spacer()

            HStack(spacing: 20) {
                Button(action: onSearchTap) {
                    Image("search").resizable().frame(width: 20, height: 20)
                }

//                Button(action: onMoreTap) {
//                    Image("verticalDot").resizable().frame(width: 3, height: 20)
//                }
            }
        }
    }
}

// 월/필터 영역(Home View와 연결->연/월)
struct DiaryMonthSectionView: View {
    @Binding var isFilterSheetPresented: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "\(Calendar.current.year())년")
                    .foregroundColor(.green04)
                    .font(.pretendardRegular(14))

                Text("\(Calendar.current.component(.month, from: Date()))월")
                    .font(.pretendardRegular(20))
                    .foregroundColor(.green08)
            }

            Spacer()

            Button {
                isFilterSheetPresented = true
            } label: {
                Image(isFilterSheetPresented ? "filter_green" : "filter_black")
                    .resizable()
                    .frame(width: 48, height: 48)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DiaryListView(container: DIContainer())
        .environmentObject(DIContainer())
}
