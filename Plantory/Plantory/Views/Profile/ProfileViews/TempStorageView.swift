import SwiftUI

struct TempStorageView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel       = TempViewModel()
    @State private var isNewSorting          = true
    @State private var isEditing             = false
    @State private var checkedItems          = Set<Int>()
    @State private var showPopUp             = false    // 삭제 확인 팝업 토글

    // 체크된 아이템 개수
    private var selectedCount: Int { checkedItems.count }

    // 정렬된 CellVM 배열
    private var sortedCells: [TempViewModel.DiaryCellViewModel] {
        viewModel.cellViewModels.sorted {
            isNewSorting
                ? $0.dateText > $1.dateText
                : $0.dateText < $1.dateText
        }
    }

    var body: some View {
        ZStack {
            // MARK: - 메인 콘텐츠
            VStack(spacing: 5) {
                // 상단 정렬 & 선택 수 표시
                AlignmentView(isNew: $isNewSorting, selectedCount: selectedCount)

                if viewModel.isLoading {
                    ProgressView()

                } else if let err = viewModel.errorMessage {
                    Text(err)
                        .foregroundColor(.red)

                } else {
                    // 일기 없으면 EmptyView
                    if sortedCells.isEmpty {
                        EmptyView(
                            mainText:   "보관한 일기가 없어요",
                            subText:    "작성 중인 일기를 보관함에 저장해 놓을 수 있어요!"
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else {
                        // 일기 있을 때 리스트
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(sortedCells) { cell in
                                    TemporaryContentView(
                                        title:      cell.title,
                                        dateText:   cell.dateText,
                                        isEditing:  $isEditing,
                                        isChecked:  Binding(
                                            get: { checkedItems.contains(cell.id) },
                                            set: { newVal in
                                                if newVal {
                                                    checkedItems.insert(cell.id)
                                                } else {
                                                    checkedItems.remove(cell.id)
                                                }
                                            }
                                        ),
                                        onNavigate: {
                                            // 네비게이션 로직
                                        }
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }

                // 하단 삭제 버튼 뷰
                TempFootView(
                    isEditing: $isEditing,
                    isEmpty:    checkedItems.isEmpty,
                    onDelete: {
                        // 삭제 버튼 눌렀을 때 팝업 띄우기
                        showPopUp = true
                    }
                )
            }
            .padding(.horizontal)
            .onChange(of: isNewSorting) { _, newValue in
                viewModel.fetchTemp(sort: newValue ? .latest : .oldest)
            }
            .customNavigation(
                title:   "임시보관함",
                leading: makeLeadingNav(),
                trailing: makeTrailingNav()
            )
            .navigationBarBackButtonHidden(true)

            // MARK: - 삭제 확인 팝업
            if showPopUp {
                PopUp(
                    title:        "보관한 일기를 삭제하시겠습니까?",
                    message:      "일기 삭제 시, 해당 일기는 휴지통으로 이동합니다.",
                    confirmTitle: "삭제하기",
                    cancelTitle:  "취소",
                    onConfirm: {
                        viewModel.moveToTrash(ids: Array(checkedItems))
                        checkedItems.removeAll()
                        isEditing = false
                        showPopUp = false
                    },
                    onCancel: {
                        showPopUp = false
                    }
                )
            }
        }
    }

    // 네비게이션 바 왼쪽
    private func makeLeadingNav() -> AnyView {
        AnyView(
            Group {
                if isEditing {
                    Button {
                        if checkedItems.count == sortedCells.count {
                            checkedItems.removeAll()
                        } else {
                            sortedCells.forEach { checkedItems.insert($0.id) }
                        }
                    } label: {
                        Text(checkedItems.count == sortedCells.count ? "전체 선택 해제" : "전체 선택")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.green07)
                    }
                } else {
                    Button { dismiss() } label: {
                        Image("leftChevron").fixedSize()
                    }
                }
            }
        )
    }

    // 네비게이션 바 오른쪽
    private func makeTrailingNav() -> AnyView {
        AnyView(
            Group {
                if isEditing {
                    Button { isEditing = false } label: {
                        Text("취소").font(.pretendardRegular(14)).foregroundStyle(.green07)
                    }
                } else {
                    Button { isEditing = true } label: {
                        Text("편집").font(.pretendardRegular(14)).foregroundStyle(.green07)
                    }
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        TempStorageView()
    }
}



struct AlignmentView: View {
    @Binding var isNew: Bool
    let selectedCount: Int
    @State private var showMenu = false

    var body: some View {
        HStack {
            Text("총 \(selectedCount)개 선택됨")
                .font(.pretendardRegular(14))
            Spacer()
            // 1) 토글 버튼만 HStack 안에
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

        // 2) overlay 로 메뉴를 얹고 layout 에 영향 주지 않기
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
                    .cornerRadius(6)
                    .shadow(color: .black.opacity(0.1), radius: 0, x: 2, y: 2)
                    .frame(width: 80)
                    .offset(x: 0, y: 40) // 버튼 바로 아래에 위치
                }
            },
            alignment: .topTrailing   // HStack의 topTrailing 기준
        )
        // 3) 다른 형제 뷰들 위로 띄우기
        .zIndex(showMenu ? 1 : 0)
    }
}



struct TemporaryContentView: View {
    let title: String
    let dateText: String
    @Binding var isEditing: Bool
    @Binding var isChecked: Bool
    let onNavigate: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.pretendardSemiBold(18))
                    .foregroundColor(.black)
                Text(dateText)
                    .font(.pretendardMedium(12))
                    .foregroundColor(.gray)
            }
            .frame(height: 48)
            Spacer()
            if isEditing {
                Button { isChecked.toggle() } label: {
                    Image(isChecked ? "Check_Filled" : "Check_Empty")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isEditing else { return }
            onNavigate()
        }
        .padding()
        .background(Color.gray02)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 0, x: 2, y: 2)
    }
}

struct TempFootView: View {
    @Binding var isEditing: Bool
    let isEmpty: Bool
    var onDelete: () -> Void   // 삭제 액션 클로저
    
    var body: some View {
        VStack {
            if isEditing {
                HStack {
                    Spacer()

                    MainSmallButton(
                        text: "삭제",
                        isDisabled: isEmpty,
                        action: onDelete
                    )
                }
            } else {
                HStack {
                    Text("보관함에 있는 항목은 이동된 날짜로부터 30일 뒤 휴지통으로 이동합니다.")
                        .font(.PretendardLight(12))
                        .foregroundColor(.gray07)
                        .padding(.vertical, 11)
                }
            }
        }
        .padding(.bottom, 10)
    }
}


#Preview {
    NavigationStack {
        TempStorageView()
    }
}
