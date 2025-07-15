import SwiftUI

struct TrashView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel      = WasteViewModel()
    @State private var isNewSorting         = true
    @State private var isEditing            = false
    @State private var checkedItems         = Set<Int>()
    @State private var showDeletePopUp            = false
    @State private var showRestorePopUp = false

    /// 선택된 아이템 개수
    private var selectedCount: Int {
        checkedItems.count
    }

    /// 정렬된 셀 뷰모델
    private var sortedCells: [WasteViewModel.DiaryCellViewModel] {
        viewModel.cellViewModels.sorted {
            isNewSorting
                ? $0.dateText > $1.dateText
                : $0.dateText < $1.dateText
        }
    }

    var body: some View {
        ZStack {
            // MARK: 메인 콘텐츠
            VStack(spacing: 5) {
                // 상단 정렬 & 선택 수
                AlignmentView(isNew: $isNewSorting, selectedCount: selectedCount)

                if viewModel.isLoading {
                    ProgressView()

                } else if let err = viewModel.errorMessage {
                    Text(err)
                        .foregroundColor(.red)

                } else {
                    if sortedCells.isEmpty {
                        EmptyView(
                            mainText:   "휴지통이 비어있습니다",
                            subText:    "삭제된 일기가 없습니다."
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(sortedCells) { cell in
                                    TemporaryContentView(
                                        title:     cell.title,
                                        dateText:  cell.dateText,
                                        isEditing: $isEditing,
                                        isChecked: Binding(
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

                // 하단 복원/삭제 버튼
                TrashFootView(
                    isEditing: $isEditing,
                    isEmpty:    checkedItems.isEmpty,
                    onRestore: {
                        // 복원 로직
                        showRestorePopUp = true
                    },
                    onDelete: {
                        // 삭제 버튼 누르면 팝업 띄우기
                        showDeletePopUp = true
                    }
                )
            }
            .padding(.horizontal)
            .onChange(of: isNewSorting) { _, newValue in
                viewModel.fetchWaste(sort: newValue ? .latest : .oldest)
            }
            .customNavigation(
                title:    "휴지통",
                leading:  makeLeadingNav(),
                trailing: makeTrailingNav()
            )
            .navigationBarBackButtonHidden(true)


            // MARK: 삭제 확인 팝업
            if showDeletePopUp {
                PopUp(
                    title:        "일기를 삭제하시겠습니까?",
                    message:      "일기 삭제 시, 해당 일기는 영구 삭제됩니다.",
                    confirmTitle: "삭제하기",
                    cancelTitle:  "취소",
                    onConfirm: {
                        viewModel.deleteForever(ids: Array(checkedItems))
                        checkedItems.removeAll()
                        // 실제로는 checkedItems.removeAll 대신 fetch() 해야함
                        isEditing = false
                        showDeletePopUp = false
                    },
                    onCancel: {
                        showDeletePopUp = false
                    }
                )
            }
            
            if showRestorePopUp {
                PopUp(
                    title:        "해당 일기를 복원하시겠습니까?",
                    message:      "일기 복원 시, 해당 일기는 유지됩니다.",
                    confirmTitle: "복원하기",
                    cancelTitle:  "취소",
                    onConfirm: {
                        // 복원 API 호출
                        isEditing = false
                        showRestorePopUp = false
                    },
                    onCancel: {
                        showRestorePopUp = false
                    }
                )
            }
        }
    }

    // 네비게이션 바 왼쪽 버튼
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

    // 네비게이션 바 오른쪽 버튼
    private func makeTrailingNav() -> AnyView {
        AnyView(
            Group {
                if isEditing {
                    Button { isEditing = false } label: {
                        Text("취소")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.green07)
                    }
                } else {
                    Button { isEditing = true } label: {
                        Text("편집")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.green07)
                    }
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        TrashView()
    }
}


/// 하단 복원/삭제 버튼 뷰
struct TrashFootView: View {
    @Binding var isEditing: Bool
    let isEmpty: Bool
    let onRestore: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack {
            if isEditing {
                HStack {
                    MainSmallButton(
                        text: "복원하기",
                        isDisabled: isEmpty,
                        action: onRestore
                    )
                    Spacer()
                    MainSmallButton(
                        text: "삭제",
                        isDisabled: isEmpty,
                        action: onDelete
                    )
                }

            } else {
                HStack {
                    Text("휴지통에 있는 항목은 이동된 날짜로부터 30일 뒤 영구삭제 됩니다.")
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
        TrashView()
    }
}
