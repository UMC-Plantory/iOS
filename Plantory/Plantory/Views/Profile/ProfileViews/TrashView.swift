import SwiftUI

struct TrashView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WasteViewModel()

    @State private var isNewSorting = true
    @State private var isEditing = false
    @State private var checkedItems = Set<Int>()
    @State private var showDeletePopUp = false
    @State private var showRestorePopUp = false

    var body: some View {
        ZStack {
            VStack(spacing: 5) {
                AlignmentView(isNew: $isNewSorting, selectedCount: checkedItems.count)

                content

                TrashFootView(
                    isEditing: $isEditing,
                    isEmpty: checkedItems.isEmpty,
                    onRestore: { showRestorePopUp = true },
                    onDelete: { showDeletePopUp = true }
                )
            }
            .padding(.horizontal)
            .onChange(of: isNewSorting) { _, newValue in
                viewModel.fetchWaste(sort: newValue ? .latest : .oldest)
            }
            .customNavigation(
                title: "휴지통",
                leading: navigationLeading,
                trailing: navigationTrailing
            )
            .navigationBarBackButtonHidden(true)

            if showDeletePopUp { deleteConfirmationPopUp }
            if showRestorePopUp { restoreConfirmationPopUp }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let error = viewModel.errorMessage {
            Text(error).foregroundColor(.red)
        } else if sortedCells.isEmpty {
            NothingView(mainText: "휴지통이 비어있습니다", subText: "삭제된 일기가 없습니다.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            diaryList
        }
    }

    private var sortedCells: [WasteViewModel.DiaryCellViewModel] {
        viewModel.cellViewModels.sorted(by: isNewSorting ? { $0.dateText > $1.dateText } : { $0.dateText < $1.dateText })
    }

    private var diaryList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(sortedCells) { cell in
                    TemporaryContentView(
                        title: cell.title,
                        dateText: cell.dateText,
                        isEditing: $isEditing,
                        isChecked: Binding(
                            get: { checkedItems.contains(cell.id) },
                            set: { isChecked in
                                if isChecked { checkedItems.insert(cell.id) }
                                else { checkedItems.remove(cell.id) }
                            }
                        ),
                        onNavigate: {}
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var navigationLeading: some View {
        Group {
            if isEditing {
                Button(action: toggleAllSelection) {
                    Text(checkedItems.count == sortedCells.count ? "전체 선택 해제" : "전체 선택")
                        .font(.pretendardRegular(14)).foregroundStyle(.green07)
                }
            } else {
                Button(action: dismiss.callAsFunction) {
                    Image("leftChevron").fixedSize()
                }
            }
        }
    }

    private var navigationTrailing: some View {
        Button(action: { isEditing.toggle() }) {
            Text(isEditing ? "취소" : "편집")
                .font(.pretendardRegular(14)).foregroundStyle(.green07)
        }
    }

    private var deleteConfirmationPopUp: some View {
        PopUp(
            title: "일기를 삭제하시겠습니까?",
            message: "일기 삭제 시, 해당 일기는 영구 삭제됩니다.",
            confirmTitle: "삭제하기",
            cancelTitle: "취소",
            onConfirm: performDeletion,
            onCancel: { showDeletePopUp = false }
        )
    }

    private var restoreConfirmationPopUp: some View {
        PopUp(
            title: "해당 일기를 복원하시겠습니까?",
            message: "일기 복원 시, 해당 일기는 유지됩니다.",
            confirmTitle: "복원하기",
            cancelTitle: "취소",
            onConfirm: performRestore,
            onCancel: { showRestorePopUp = false }
        )
    }

    private func toggleAllSelection() {
        if checkedItems.count == sortedCells.count {
            checkedItems.removeAll()
        } else {
            checkedItems = Set(sortedCells.map { $0.id })
        }
    }

    private func performDeletion() {
        viewModel.deleteForever(ids: Array(checkedItems))
        // 실제로 삭제할 때는 fetch()로 수정된 리스트 불러오기 !!
        checkedItems.removeAll()
        isEditing = false
        showDeletePopUp = false
    }

    private func performRestore() {
        // 복원 API 호출
        isEditing = false
        showRestorePopUp = false
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
                        .font(.pretendardLight(12))
                        .foregroundColor(.gray08)
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
