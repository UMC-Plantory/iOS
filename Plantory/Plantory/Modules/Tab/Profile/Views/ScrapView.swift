//
//  ScrapView.swift
//  Plantory
//
//  Created by 이효주 on 7/8/25.
//

import SwiftUI

struct ScrapView: View {
    @EnvironmentObject var container: DIContainer
    
    @StateObject private var viewModel: ScrapViewModel
    
    @State private var showMenu = false
    @State private var isNew = true
    @State private var checkedItems = Set<Int>()
    
    init(
        container: DIContainer
    ) {
        _viewModel = StateObject(
           wrappedValue: ScrapViewModel(container: container)
        )
    }
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Spacer()
                
                Button {
                    showMenu.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Text(isNew ? "최신순" : "오래된순")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.black01)
                            .offset(x: 15)
                        if showMenu {
                            Image("Up")
                        } else {
                            Image("Down")
                        }
                    }
                    .background(Color.white)
                }
            }
            
            Spacer()

            content
        }
        .overlay(
            Group {
                if showMenu {
                    VStack(spacing: 0) {
                        Button {
                            isNew = true
                            showMenu = false
                        } label: {
                            Text("최신순")
                                .font(isNew ? .pretendardSemiBold(10) : .pretendardRegular(10))
                                .foregroundColor(isNew ? .green06 : .black)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button {
                            isNew = false
                            showMenu = false
                        } label: {
                            Text("오래된순")
                                .font(!isNew ? .pretendardSemiBold(10) : .pretendardRegular(10))
                                .foregroundColor(!isNew ? .green06 : .black)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 0, x: 2, y: 2)
                    .frame(width: 80)
                    .offset(x: 0, y: 40) // 버튼 바로 아래에 위치
                }
            },
            alignment: .topTrailing   // HStack의 topTrailing 기준
        )
        .zIndex(showMenu ? 1 : 0)
        .onChange(of: isNew) {
            Task {
                viewModel.hasNext = true
                viewModel.diaries = []
                await viewModel.fetchFilteredDiaries(sort: isNew ? .latest : .oldest)
            }
        }
        .customNavigation(
            title: "스크랩",
            leading: Button(action: { container.navigationRouter.pop()
            }, label: {
                Image("leftChevron").fixedSize()
            }
        ))
        .navigationBarBackButtonHidden(true)
        .toastView(toast: $viewModel.toast)
        .onAppear {
            Task {
                viewModel.hasNext = true
                viewModel.diaries = []
                await viewModel.fetchFilteredDiaries(sort: isNew ? .latest : .oldest)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.diaries.isEmpty {
            NothingView(mainText: "스크랩 한 일기가 없어요", subText: "오래 보관하고 싶은 일기를 스크랩 해보세요!", buttonTitle: "리스트 페이지로 이동하기", buttonAction: {
                container.navigationRouter.pop()
            })
            Spacer()
        } else {
            DiaryListContent
        }
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
                                await viewModel.fetchFilteredDiaries(sort: isNew ? .latest : .oldest)
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

#Preview {
    NavigationStack {
        ScrapView(container: DIContainer())
    }
}
