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
                container: container
            )
        )
    }

    var body: some View {
        ZStack {
            Color.searchbackground.ignoresSafeArea()
            
            VStack(spacing: 10) {
                topBar()
                    .padding(.horizontal, 16)
                if vm.results.isEmpty {
                    recentSearchSection()
                        .padding(.horizontal, 16)
                } else {
                    searchResultSection
                }
            }
            .padding(.top, 25)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden()
        .overlay {
            if vm.isLoading { ProgressView().scaleEffect(1.1) }
        }
        .task {
            UIApplication.shared.hideKeyboard()
        }
        .toastView(toast: $vm.toast)
    }

    // MARK: - Sections

    @ViewBuilder
    private func topBar() -> some View {
        HStack {
            Button {
                container.navigationRouter.pop()
            } label: {
                Image("leftChevron")
                    .renderingMode(.template)
                    .foregroundColor(.black01)
            }

            HStack {
                searchField()
                
                Spacer()
                
                searchButton()
            }
            .padding(.horizontal, 14)
            .background(.searchbar)
            .cornerRadius(30)
        }
    }

    private func searchField() -> some View {
        TextField("키워드를 입력하세요", text: $vm.query)
            .padding(.vertical, 10)
            .background(.searchbar)
            .foregroundColor(.gray10)
            .submitLabel(.search)
            .onSubmit {
                let q = vm.query.trimmingCharacters(in: .whitespacesAndNewlines)
                Task {
                    vm.query = q
                    vm.results.removeAll()
                    vm.cursor = nil
                    vm.hasNext = false
                    vm.currentKeywords = ""
                    await vm.searchDiary(keyword: q)
                }
            }
    }

    private func searchButton() -> some View {
        Button {
            guard !vm.query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            Task {
                vm.results.removeAll()
                vm.cursor = nil
                vm.hasNext = false
                vm.currentKeywords = ""
                await vm.searchDiary(keyword: vm.query)
            }
        } label: {
            Image("search")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.black01)
                .frame(width: 20, height: 20)
        }
    }

    @ViewBuilder
    private func recentSearchSection() -> some View {
        HStack {
            Text("최근 검색어")
                .font(.pretendardSemiBold(18))
                .foregroundColor(.black01)
            Spacer()
            Button("모두 지우기") { vm.clearRecent() }
                .font(.pretendardRegular(12))
                .foregroundColor(.gray08)
        }
        .padding(.vertical, 16)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.recentKeywords, id: \.self) { keyword in
                    recentKeywordChip(keyword: keyword)
                }
            }
        }
        
        Spacer()
    }

    private func recentKeywordChip(keyword: String) -> some View {
        HStack(spacing: 4) {
            Button {
                Task {
                    vm.query = keyword
                    vm.results.removeAll()
                    vm.cursor = nil
                    vm.hasNext = false
                    vm.currentKeywords = ""
                    await vm.searchDiary(keyword: keyword)
                }
            } label: {
                Text(keyword)
                    .font(.pretendardRegular(16))
                    .foregroundColor(Color("gray06"))
            }
            Button {
                if let i = vm.recentKeywords.firstIndex(of: keyword) {
                    vm.recentKeywords.remove(at: i)
                }
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.gray08)
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
    private var searchResultSection: some View {
        Rectangle()
            .fill(Color.gray04)
            .frame(height: 4)
            .padding(.horizontal, -18)
            .padding(.bottom, 24)
        
        HStack {
            Text("‘\(vm.currentKeywords)’가 들어간 일기")
                .font(.pretendardSemiBold(18))
                .foregroundColor(Color("black01"))
            Spacer()
            Text("\(vm.total)개")
                .font(.pretendardRegular(12))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(vm.results) { diary in
                    Button {
                        container.navigationRouter.push(.diaryDetail(diaryId: diary.diaryId))
                    } label: {
                        DiaryRow(entry: diary)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if diary.id == vm.results.last?.id {
                            Task {
                                await vm.searchDiary(keyword: vm.query)
                            }
                        }
                    }
                }
                
                if vm.isLoading {
                    ProgressView().padding()
                }
            }
        }
    }
}

#Preview {
    DiarySearchView(container: DIContainer())
        .environmentObject(DIContainer())
}
