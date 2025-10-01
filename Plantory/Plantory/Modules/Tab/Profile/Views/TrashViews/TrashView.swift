import SwiftUI

struct TrashView: View {
    private let container: DIContainer
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: WasteViewModel
    
    init(container: DIContainer) {
            self.container = container
            _viewModel = StateObject(wrappedValue: WasteViewModel(container: container))
        }

    @State private var isNewSorting = true
    @State private var isEditing = false
    @State private var checkedItems = Set<Int>()
    @State private var showDeletePopUp = false
    @State private var showRestorePopUp = false

    var body: some View {
        VStack(spacing: 5) {
            AlignmentView(isNew: $isNewSorting, selectedCount: checkedItems.count)

            content

            TrashFootView(
                isEditing: $isEditing,
                isEmpty: checkedItems.isEmpty,
                onRestore: { withAnimation(.spring()) { showRestorePopUp = true } },
                onDelete: { withAnimation(.spring()) { showDeletePopUp = true } }
            )
        }
        .padding(.horizontal, 8)
        .onChange(of: isNewSorting) { _, newValue in
            viewModel.fetchWaste(sort: newValue ? .latest : .oldest)
        }
        .customNavigation(
            title: "휴지통",
            leading: navigationLeading,
            trailing: navigationTrailing
        )
        .navigationBarBackButtonHidden(true)
        .popup(
            isPresented: $showDeletePopUp,
            title: "일기를 삭제하시겠습니까?",
            message: "일기 삭제 시, 해당 일기는 영구 삭제됩니다.",
            confirmTitle: "삭제하기",
            cancelTitle: "취소",
            onConfirm: performDeletion
        )
        .popup(
            isPresented: $showRestorePopUp,
            title: "해당 일기를 복원하시겠습니까?",
            message: "일기 복원 시, 해당 일기는 유지됩니다.",
            confirmTitle: "복원하기",
            cancelTitle: "취소",
            onConfirm: performRestore
        )
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            Text(error).foregroundColor(.red)
        } else if sortedCells.isEmpty {
            NothingView(mainText: "휴지통이 비어있습니다", subText: "삭제된 일기가 없습니다.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            diaryList
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        onNavigate: {
                            container.navigationRouter.push(.diaryDetail(diaryId: cell.id))
                        }
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

    private func toggleAllSelection() {
        if checkedItems.count == sortedCells.count {
            checkedItems.removeAll()
        } else {
            checkedItems = Set(sortedCells.map { $0.id })
        }
    }

    private func performDeletion() {
        withAnimation(.spring()) { showDeletePopUp = false }
        // Call Delete API
        viewModel.deleteForever(ids: Array(checkedItems))
        checkedItems.removeAll()
        isEditing = false
    }

    private func performRestore() {
        withAnimation(.spring()) { showRestorePopUp = false }
        // 복원 API 호출
        viewModel.restoreWaste(ids: Array(checkedItems))
        checkedItems.removeAll()
        isEditing = false
    }
}



#Preview {
    NavigationStack { TrashView(container: .init()) }
}
