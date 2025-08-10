import SwiftUI

struct TempStorageView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = TempViewModel()
    @State private var isNewSorting = true
    @State private var isEditing = false
    @State private var checkedItems = Set<Int>()
    @State private var showPopUp = false

    var body: some View {
        ZStack {
            VStack(spacing: 5) {
                AlignmentView(isNew: $isNewSorting, selectedCount: checkedItems.count)

                content

                TempFootView(
                    isEditing: $isEditing,
                    isEmpty: checkedItems.isEmpty,
                    onDelete: { showPopUp = true }
                )
            }
            .padding(.horizontal)
            .onChange(of: isNewSorting) { _, newValue in
                viewModel.fetchTemp(sort: newValue ? .latest : .oldest)
            }
            .customNavigation(
                title: "임시보관함",
                leading: navigationLeading,
                trailing: navigationTrailing
            )
            .navigationBarBackButtonHidden(true)

            if showPopUp {
                deleteConfirmationPopUp
            }
        }
    }

    // MARK: - 콘텐츠 뷰
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let error = viewModel.errorMessage {
            Text(error).foregroundColor(.red)
        } else if sortedCells.isEmpty {
            NothingView(mainText: "보관한 일기가 없어요", subText: "작성 중인 일기를 보관함에 저장해 놓을 수 있어요!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            diaryList
        }
    }

    private var sortedCells: [TempViewModel.DiaryCellViewModel] {
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
                                if isChecked {
                                    checkedItems.insert(cell.id)
                                } else {
                                    checkedItems.remove(cell.id)
                                }
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

    // MARK: - 네비게이션 바 구성요소
    private var navigationLeading: some View {
        Group {
            if isEditing {
                Button(action: toggleAllSelection) {
                    Text(checkedItems.count == sortedCells.count ? "전체 선택 해제" : "전체 선택")
                        .font(.pretendardRegular(16)).foregroundStyle(.green07)
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
                .font(.pretendardRegular(16)).foregroundStyle(.green07)
        }
    }

    // MARK: - 삭제 확인 팝업
    private var deleteConfirmationPopUp: some View {
        PopUp(
            title: "보관한 일기를 삭제하시겠습니까?",
            message: "일기 삭제 시, 해당 일기는 휴지통으로 이동합니다.",
            confirmTitle: "삭제하기",
            cancelTitle: "취소",
            onConfirm: performDeletion,
            onCancel: { showPopUp = false }
        )
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
        viewModel.moveToTrash(ids: Array(checkedItems))
        checkedItems.removeAll()
        isEditing = false
        showPopUp = false
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
                    .cornerRadius(8)
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
        TempStorageView()
    }
}
