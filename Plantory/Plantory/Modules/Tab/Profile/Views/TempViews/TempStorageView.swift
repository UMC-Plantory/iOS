import SwiftUI

struct TempStorageView: View {
    @Environment(\.dismiss) private var dismiss
    private let container: DIContainer
    
    @StateObject private var viewModel: TempViewModel
    
    init(container: DIContainer) {
            self.container = container
            _viewModel = StateObject(wrappedValue: TempViewModel(container: container))
        }
    
    @State private var isNewSorting = true
    @State private var isEditing = false
    @State private var checkedItems = Set<Int>()
    @State private var showPopUp = false

    var body: some View {
        ZStack {
            Color.adddiarybackground.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Divider().background(.gray04)
                
                VStack(spacing: 5) {
                    
                    AlignmentView(isNew: $isNewSorting, selectedCount: checkedItems.count)
                    
                    content
                    
                    TempFootView(
                        isEditing: $isEditing,
                        isEmpty: checkedItems.isEmpty,
                        onDelete: { withAnimation(.spring()) { showPopUp = true } }
                    )
                }
                .padding(.horizontal)
            }
            .padding(.horizontal, 8)
            .onAppear {
                // 화면이 다시 보일 때 현재 정렬 기준으로 목록 재조회
                viewModel.fetchTemp(sort: isNewSorting ? .latest : .oldest)
            }
            .onChange(of: isNewSorting) { _, newValue in
                viewModel.fetchTemp(sort: newValue ? .latest : .oldest)
            }
            .popup(
                isPresented: $showPopUp,
                title: "보관한 일기를 삭제하시겠습니까?",
                message: "일기 삭제 시, 해당 일기는 휴지통으로 이동합니다.",
                confirmTitle: "삭제하기",
                cancelTitle: "취소",
                onConfirm: performDeletion
            )
            .customNavigation(
                title: "임시보관함",
                leading: navigationLeading,
                trailing: navigationTrailing
            )
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - 콘텐츠 뷰
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            Text(error).foregroundColor(.red)
        } else if sortedCells.isEmpty {
            NothingView(mainText: "보관한 일기가 없어요", subText: "작성 중인 일기를 보관함에 저장해 놓을 수 있어요!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            diaryList
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // 최신순 / 오래된순 정렬
    private var sortedCells: [TempViewModel.DiaryCellViewModel] {
        viewModel.cellViewModels.sorted(by: isNewSorting ? { $0.dateText > $1.dateText } : { $0.dateText < $1.dateText })
    }

    // 임시보관함 리스트
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
                                if isChecked {
                                    checkedItems.insert(cell.id)
                                } else {
                                    checkedItems.remove(cell.id)
                                }
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

    // MARK: - 네비게이션 바 구성요소
    private var navigationLeading: some View {
        Group {
            if isEditing {
                Button(action: toggleAllSelection) {
                    Text(checkedItems.count == sortedCells.count ? "전체 선택 해제" : "전체 선택")
                        .font(.pretendardRegular(16)).foregroundStyle(.green07Dynamic)
                }
            } else {
                Button(action: dismiss.callAsFunction) {
                    Image("leftChevron")
                        .renderingMode(.template)
                        .foregroundStyle(.black01Dynamic)
                        .fixedSize()
                }
            }
        }
    }

    private var navigationTrailing: some View {
        Button(action: { isEditing.toggle() }) {
            Text(isEditing ? "취소" : "편집")
                .font(.pretendardRegular(16)).foregroundStyle(.green07Dynamic)
        }
    }

    // MARK: - 액션
    private func toggleAllSelection() {
        if checkedItems.count == sortedCells.count {
            checkedItems.removeAll()
        } else {
            checkedItems = Set(sortedCells.map { $0.id })
        }
    }

    private func performDeletion() {
        withAnimation(.spring()) { showPopUp = false }
        viewModel.moveToTrash(ids: Array(checkedItems))
        checkedItems.removeAll()
        isEditing = false
        // 삭제 후에도 최신 상태를 보장하고 싶다면 아래 줄을 추가할 수 있습니다.
        // viewModel.fetchTemp(sort: isNewSorting ? .latest : .oldest)
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
                        .font(.pretendardLight(12))
                        .foregroundColor(.gray08Dynamic)
                        .padding(.vertical, 11)
                }
            }
        }
        .padding(.bottom, 10)
    }
}


#Preview {
    NavigationStack { TempStorageView(container: .init()) }
}
