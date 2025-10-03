//
//  SearchResultView.swift
//  Plantory
//
//  Created by 박병선 on 8/19/25.
//
import SwiftUI

// MARK: - 부모: 상태에 따라 적절한 서브뷰를 고른다
struct SearchResultsView: View {
    // 기존 파라미터
    let results: [DiarySummary]
    let isLoading: Bool
    let error: String?
    let hasNext: Bool
    let onLoadMore: () -> Void
    let onRetry: () -> Void   // 에러 시 재시도

    //  추가: 상단 검색바를 위한 바인딩/액션
    @Binding var query: String
    let onSearch: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            topBar() // 상단 바
                .padding(.vertical, 10)
                .padding(.horizontal, 8)

            // 본문
            Group {
                if let error {
                    ErrorStateView(error: error, onRetry: onRetry)
                } else if results.isEmpty && !isLoading {
                    EmptyStateView()
                } else {
                    ResultsListView(
                        results: results,
                        isLoading: isLoading,
                        hasNext: hasNext,
                        onLoadMore: onLoadMore
                    )
                }
            }
        }
    }

    // MARK: - Top Bar
    @ViewBuilder
    private func topBar() -> some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("black01"))
                    .frame(width: 28, height: 28, alignment: .center)
                    .padding(.leading, 5)
            }

            HStack(spacing: 8) {
                searchField()
                searchButton()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color("brown01"))
            .cornerRadius(30)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Search Field / Button
    @ViewBuilder
    private func searchField() -> some View {
        TextField("검색어를 입력하세요", text: $query, onCommit: onSearch)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundColor(Color("black01"))
    }

    @ViewBuilder
    private func searchButton() -> some View {
        Button {
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            onSearch()
        } label: {
            Image("search")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(.trailing, 4)
        }
    }
}

// MARK: - 서브뷰들

private struct ErrorStateView: View {
    let error: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("오류가 발생했어요")
                .font(.headline)
            Text(error)
                .foregroundColor(.secondary)
                .font(.footnote)
                .multilineTextAlignment(.center)
            Button("다시 시도", action: onRetry)
        }
        .padding(.top, 32)
        .padding(.horizontal, 20)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("검색 결과가 없어요")
            Text("검색어 또는 필터를 확인해보세요")
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .padding(.top, 32)
    }
}

private struct ResultsListView: View {
    let results: [DiarySummary]
    let isLoading: Bool
    let hasNext: Bool
    let onLoadMore: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(results) { item in
                    DiarySearchRow(entry: item)
                        .onAppear {
                            if item.id == results.last?.id {
                                onLoadMore()
                            }
                        }
                        .padding(.horizontal, 16)
                }
                if isLoading {
                    ProgressView().padding()
                } else if hasNext {
                    Button("더 불러오기", action: onLoadMore)
                        .padding(.vertical, 12)
                }
            }
            .padding(.top, 8)
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    ResultsListView(
        results: [
            DiarySummary(
                diaryId: 1,
                diaryDate: "09.25",
                title: "가을 산책",
                status: "NORMAL", emotion: .HAPPY,
                content: "오늘은 날씨가 좋아서 공원에 다녀왔다. 시원한 바람이 기분을 좋게 했다.",
                diaryImgUrl: nil,
                aiComment: nil
            ),
            DiarySummary(
                diaryId: 2,
                diaryDate: "09.24",
                title: "비 오는 날",
                status: "NORMAL", emotion: .SAD,
                content: "하루 종일 비가 와서 기분이 조금 가라앉았다. 그래도 따뜻한 차를 마시니 한결 나아졌다.",
                diaryImgUrl: nil,
                aiComment: nil
            ),
            DiarySummary(
                diaryId: 3,
                diaryDate: "09.23",
                title: "스터디 모임",
                status: "NORMAL", emotion: .SOSO,
                content: "친구들과 모여서 공부했다. 진도는 많이 못 나갔지만 유익한 시간이 되었다.",
                diaryImgUrl: nil,
                aiComment: nil
            )
        ],
        isLoading: false,
        hasNext: true,
        onLoadMore: {
            print("Load more diaries…")
        }
    )
}
