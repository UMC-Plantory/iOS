//
//  DiaryView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//
import SwiftUI

// 일기 리스트 화면
struct DiaryListView: View {
    @StateObject private var viewModel: DiaryListViewModel
    @Binding var isFilterSheetPresented: Bool
    @State private var isNavigatingToSearch = false
    @EnvironmentObject var container: DIContainer

    init(
           isFilterSheetPresented: Binding<Bool>,
           container: DIContainer
       ) {
           _isFilterSheetPresented = isFilterSheetPresented
           _viewModel = StateObject(
               wrappedValue: DiaryListViewModel(container: container)
           )
       }

    var body: some View {
        ZStack {
            Color("brown01").ignoresSafeArea()

            VStack(spacing: 0) {
                DiaryHeaderView(
                    onSearchTap: { isNavigatingToSearch = true }
                )

                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 5)

                DiaryMonthSectionView(isFilterSheetPresented: $isFilterSheetPresented)

                DiaryListContent(
                    entries: viewModel.entries,
                        isLoading: viewModel.isLoading,
                        onAppearLast: { viewModel.loadMoreMock() },
                        onTap: { entry in
                            viewModel.fetchDiary(diaryId: entry.id)
                            container.navigationRouter.path.append(NavigationDestination.diaryDetail(diaryId: entry.id))
                        }
                )
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            DiaryFilterView(initialSelectedMonths: [4, 5])
        }
        .navigationDestination(isPresented: $isNavigatingToSearch) {
            // 검색 화면으로 이동
            DiarySearchView(container: container)
        }
    }
}

// 스크롤 리스트만 분리
private struct DiaryListContent: View {
    let entries: [DiaryEntry]
    let isLoading: Bool
    let onAppearLast: () -> Void
    let onTap: (DiaryEntry) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(entries) { entry in
                    Button {
                        onTap(entry)
                    } label: {
                        DiaryRow(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if entry.id == entries.last?.id { // Identifiable 가정
                            onAppearLast()
                        }
                    }
                }

                if isLoading {
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
                .font(.pretendardSemiBold(24))
                .foregroundColor(Color("black01"))
                .padding(.vertical, 16)
                .padding(.leading, 17)
                .fixedSize()

            Spacer()

            HStack(spacing: 20) {
                Button(action: onSearchTap) {
                    Image("search").resizable().frame(width: 20, height: 20)
                }

                Button(action: onMoreTap) {
                    Image("verticalDot").resizable().frame(width: 3, height: 20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

// 월/필터 영역
struct DiaryMonthSectionView: View {
    @Binding var isFilterSheetPresented: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("2025년")
                    .foregroundColor(Color("green04"))
                    .font(.pretendardRegular(14))
                    .padding(.top, 18)
                    .padding(.leading, 17)

                Text("5월")
                    .font(.pretendardRegular(20))
                    .foregroundColor(Color("green08"))
                    .padding(.leading, 17)
            }

            Spacer()

            Button {
                isFilterSheetPresented = true
            } label: {
                Image("filter_gray")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .padding(.top, 33)
            }
        }
        .padding(.horizontal)
        .background(Color("brown01"))
    }
}
