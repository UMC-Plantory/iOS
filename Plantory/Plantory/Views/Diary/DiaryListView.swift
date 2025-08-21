//
//  DiaryView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//
import SwiftUI

// 일기 리스트페이지 입니다.
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

                DiaryListContent (//개별 리스트
                    diaries: viewModel.diaries,
                        isLoading: viewModel.isLoading,
                        onAppearLast: { viewModel.fetchMore( ) },
                        onTap: { entry in
                            viewModel.fetchDiary(diaryId: entry.id)//개별 일기 조회
                            container.navigationRouter.path.append(NavigationDestination.diaryDetail(diaryId: entry.id))//DiaryCheckView로 이동합니다
                        }
                )
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            DiaryFilterView(initialSelectedMonths: [4, 5])// 리스트 필터
        }
        .navigationDestination(isPresented: $isNavigatingToSearch) {
            DiarySearchView(container: container)//검색화면으로 이동합니다.
        }
    }
}

// 스크롤 리스트만 분리
private struct DiaryListContent: View {
    let diaries: [DiarySummary]
    let isLoading: Bool
    let onAppearLast: () -> Void
    let onTap: (DiarySummary) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(diaries) { diary in
                    Button {
                        onTap(diary)
                    } label: {
                        DiaryRow(entry: diary)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if diary.id == diaries.last?.id { // Identifiable 가정
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

// 월/필터 영역(Home View와 연결->연/월)
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



// MARK: - Preview
struct DiaryListView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isFilterSheetPresented = false
        private let container = DIContainer() // 더미 DIContainer
        
        var body: some View {
            NavigationStack {
                DiaryListView(
                    isFilterSheetPresented: $isFilterSheetPresented,
                    container: container
                )
                .environmentObject(container) // 필요하다면 주입
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.device)
    }
}
