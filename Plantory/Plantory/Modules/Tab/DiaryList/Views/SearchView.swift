//
//  SearchView.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import SwiftUI

struct DiarySearchView: View {
    @EnvironmentObject var container: DIContainer
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm: SearchViewModel

    // DIContainer을 주입받아 초기화 (VM 만들 때 사용)
    init(container: DIContainer) {
        _vm = StateObject(
            wrappedValue: SearchViewModel(
                diaryService: container.useCaseService.diaryService
            )
        )
    }

    var body: some View {
        VStack(spacing: 10) {
            topBar()
            if vm.results.isEmpty {
                recentSearchSection()
            } else {
                searchResultSection()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 25)
        .ignoresSafeArea(.keyboard)
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden()
        .overlay {
            if vm.isLoading { ProgressView().scaleEffect(1.1) }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private func topBar() -> some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("black01"))
                    .padding(.leading, 13)
            }

            HStack {
                searchField()
                searchButton()
            }
            .background(Color("brown01"))
            .cornerRadius(30)
        }
        .padding(.trailing, 16)
    }

    private func searchField() -> some View {
        TextField("키워드를 입력하세요", text: $vm.query)
            .padding(11)
            .background(Color("brown01"))
            .foregroundColor(Color("gray08"))
            .padding(.leading, 15)
            .submitLabel(.search)
            .onSubmit {
                let q = vm.query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !q.isEmpty else {
                    vm.results = []
                    return
                }
                vm.searchDiary(keyword: q)
            }
    }

    private func searchButton() -> some View {
        Button {
            guard !vm.query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            vm.searchDiary(keyword: vm.query)
        } label: {
            Image("search")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(.trailing, 13)
        }
    }

    @ViewBuilder
    private func recentSearchSection() -> some View {
        HStack {
            Text("최근 검색어")
                .font(.pretendardSemiBold(18))
                .foregroundColor(Color("black01"))
            Spacer()
            Button("모두 지우기") { vm.clearRecent() }
                .font(.pretendardRegular(12))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top, 8)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.recentKeywords, id: \.self) { keyword in
                    recentKeywordChip(keyword: keyword)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 25)
        }
        Spacer()
    }

    private func recentKeywordChip(keyword: String) -> some View {
        HStack(spacing: 4) {
            Button {
                vm.query = keyword
                vm.searchDiary(keyword: keyword)
            } label: {
                Text(keyword)
                    .font(.pretendardRegular(16))
                    .foregroundColor(Color("gray10"))
            }
            Button {
                if let i = vm.recentKeywords.firstIndex(of: keyword) {
                    vm.recentKeywords.remove(at: i)
                }
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func searchResultSection() -> some View {
        let _: DiarySummary
        HStack {
            Text("‘\(vm.query)’가 들어간 일기")
                .font(.pretendardSemiBold(18))
                .foregroundColor(Color("black01"))
            Spacer()
            Text("\(vm.results.count)개")
                .font(.pretendardRegular(12))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        
        List(vm.results, id: \.diaryId) { item in
            Button {
                container.navigationRouter.path.append(
                  NavigationDestination.diaryDetail(diaryId: item.diaryId)
                )
            } label: {
                DiaryRow(entry: item)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    let c = DIContainer()
    return DiarySearchView(container: c)
        .environmentObject(c)   // EnvironmentObject 주입 필수!
}
