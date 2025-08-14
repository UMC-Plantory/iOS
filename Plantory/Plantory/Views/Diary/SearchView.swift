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
    
    let summary: DiarySummary
    // ViewModel 주입 초기화 (중요!)
    @StateObject private var vm: SearchViewModel

    init(container: DIContainer) {
        _vm = StateObject(
            wrappedValue: SearchViewModel(
                diaryService: container.useCaseService.diaryService
            )
        )
    }

    var body: some View {
        VStack(spacing: 10) {
            // 상단 검색바
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("black01"))
                        .padding(.leading, 13)
                }

                HStack {
                    TextField("키워드를 입력하세요", text: $vm.query)
                        .padding(11)
                        .background(Color("brown01"))
                        .foregroundColor(Color("gray08"))
                        .padding(.leading, 15)
                        .submitLabel(.search)
                        .onSubmit {
                            let q = vm.query.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !q.isEmpty else {
                                vm.results = []      // 비었을 때 결과 비우고 끝내고 싶으면
                                return
                            }
                            vm.searchDiary(keyword: q)
                        }

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
                .background(Color("brown01"))
                .cornerRadius(30)
            }
            .padding(.trailing, 16)

            if vm.results.isEmpty {
                // 최근 검색어
                HStack {
                    Text("최근 검색어")
                        .font(.pretendardSemiBold(18))
                        .foregroundColor(Color("black01"))
                    Spacer()
                    Button("모두 지우기") {
                        vm.clearRecent()
                    }
                    .font(.pretendardRegular(12))
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // 최근 검색어 칩 (가로 스크롤)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.recentKeywords, id: \.self) { keyword in
                            HStack(spacing: 4) {
                                Button {
                                    vm.query = keyword
                                    vm.searchNow(keyword: keyword)
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
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 25)
                }

                Spacer()
            } else {
                // 결과 섹션 헤더
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

                // 결과 리스트
                List(vm.results, id: \.diaryId) { item in
                    Button {
                        // 상세로 내비게이션
                        container.navigationRouter.path.append(.DiarySummary(id: item.diaryId))
                    } label: {
                        DiaryRow(summary: item) // 프로젝트에 있는 셀/컴포넌트로 대체해도 OK
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 25)
        .ignoresSafeArea(.keyboard)
        .padding(.trailing, 16)
        .padding(.leading, 13)
        .overlay {
            if vm.isLoading { ProgressView().scaleEffect(1.1) }
        }
    }
}

    
#Preview {
    DiarySearchView()
}
