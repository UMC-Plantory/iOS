import SwiftUI

/// 휴지통 뷰 - 임시보관함 뷰와 동일한 구조로, 하단에 복원/삭제 버튼을 제공합니다.
struct TrashView: View {
    @Environment(\ .dismiss) private var dismiss
    @StateObject private var viewModel = WasteViewModel()    // TempViewModel과 유사하게 waste API 호출
    @State private var isNewSorting = true
    @State private var isEditing = false
    @State private var checkedItems = Set<Int>()

    /// 선택된 아이템 개수
    private var selectedCount: Int {
        checkedItems.count
    }

    /// 정렬된 뷰모델 셀 배열
    private var sortedCells: [WasteViewModel.DiaryCellViewModel] {
        viewModel.cellViewModels.sorted {
            isNewSorting ? $0.dateText > $1.dateText : $0.dateText < $1.dateText
        }
    }

    var body: some View {
        VStack(spacing: 5) {
            // 상단 정렬 & 선택 수 표시
            AlignmentView(isNew: $isNewSorting, selectedCount: selectedCount)

            if viewModel.isLoading {
                ProgressView()
            } else if let err = viewModel.errorMessage {
                Text(err)
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(sortedCells) { cell in
                            TemporaryContentView(
                                title: cell.title,
                                dateText: cell.dateText,
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

            // 하단 복원/삭제 버튼 뷰
            TrashFootView(
                isEditing: $isEditing,
                isEmpty: checkedItems.isEmpty,
                onRestore: {
                    // 복원 처리
                },
                onDelete: {
                    // 영구 삭제 처리
                }
            )
        }
        .padding(.horizontal)
        .onChange(of: isNewSorting) { _, newValue in
            viewModel.fetchWaste(sort: newValue ? .latest : .oldest)
        }
        .customNavigation(
            title: "휴지통",
            leading: AnyView(
                Group {
                    if isEditing {
                        Button {
                            // 전체 선택/해제
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
                        Button {
                            dismiss()
                        } label: {
                            Image("leftChevron").fixedSize()
                        }
                    }
                }
            ),
            trailing: AnyView(
                Group {
                    if isEditing {
                        Button {
                            isEditing = false
                        } label: {
                            Text("취소")
                                .font(.pretendardRegular(14))
                                .foregroundStyle(.green07)
                        }
                    } else {
                        Button {
                            isEditing = true
                        } label: {
                            Text("편집")
                                .font(.pretendardRegular(14))
                                .foregroundStyle(.green07)
                        }
                    }
                }
            )
        )
        .navigationBarBackButtonHidden(true)
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
