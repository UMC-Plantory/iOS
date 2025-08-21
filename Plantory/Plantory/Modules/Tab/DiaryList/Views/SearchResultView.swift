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
// MARK: - Preview
struct SearchResultsView_Previews: PreviewProvider {

    // 샘플 데이터
    static let sampleResults: [DiarySummary] = [
        DiarySummary(
            diaryId: 1,
            diaryDate: "2025-08-19",
            title: "첫 번째 일기",
            status: "NORMAL",
            emotion: "HAPPY",
            content: "오늘은 날씨가 좋아서 산책을 했다."
        ),
        DiarySummary(
            diaryId: 2,
            diaryDate: "2025-08-18",
            title: "두 번째 일기",
            status: "NORMAL",
            emotion: "SAD",
            content: "SwiftUI를 공부하며 하루를 보냈다."
        ),
        DiarySummary(
            diaryId: 3,
            diaryDate: "2025-08-17",
            title: "세 번째 일기",
            status: "SCRAP",
            emotion: "ANGRY",
            content: "커피를 쏟아서 살짝 당황했다."
        )
    ]

    // 바인딩을 주기 위한 래퍼
    struct Wrapper: View {
        @State private var query = "가나다"

        var body: some View {
            SearchResultsView(
                results: sampleResults,
                isLoading: false,
                error: nil,
                hasNext: true,
                onLoadMore: { print("더 불러오기") },
                onRetry: { print("다시 시도") },
                query: $query,
                onSearch: { print("검색 실행: \(query)") }
            )
        }
    }

    // 빈/로딩/에러 상태도 확인해보면 좋아요
    struct EmptyWrapper: View {
        @State private var query = ""
        var body: some View {
            SearchResultsView(
                results: [],
                isLoading: false,
                error: nil,
                hasNext: false,
                onLoadMore: {},
                onRetry: {},
                query: $query,
                onSearch: {}
            )
        }
    }

    struct LoadingWrapper: View {
        @State private var query = "로딩중"
        var body: some View {
            SearchResultsView(
                results: sampleResults,
                isLoading: true,
                error: nil,
                hasNext: true,
                onLoadMore: {},
                onRetry: {},
                query: $query,
                onSearch: {}
            )
        }
    }

    struct ErrorWrapper: View {
        @State private var query = "에러"
        var body: some View {
            SearchResultsView(
                results: [],
                isLoading: false,
                error: "네트워크 연결을 확인해 주세요.",
                hasNext: false,
                onLoadMore: {},
                onRetry: { print("재시도") },
                query: $query,
                onSearch: {}
            )
        }
    }

    static var previews: some View {
        Group {
            Wrapper().previewDisplayName("결과")
            EmptyWrapper().previewDisplayName("빈 상태")
            LoadingWrapper().previewDisplayName("로딩")
            ErrorWrapper().previewDisplayName("에러")
        }
    }
}
