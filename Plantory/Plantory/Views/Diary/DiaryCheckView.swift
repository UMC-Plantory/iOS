//
//  DiaryCheckView.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//
import SwiftUI

//개별일기를 확인하는 View
struct DiaryCheckView: View {
    @State private var isSaved = false //저장 상태변수
    @State private var isEditing = false // 수정 상태변수
    @Environment(\.presentationMode) var presentationMode
    
    //MARK: -입력 파라미터(외부에서 값을 주입받아야함
    let summary: DiarySummary
    let diary: DiaryEntry
    let container: DIContainer
    @Binding var isDeleteSheetPresented: Bool
    
    // VM 은 init에서 주입
    @StateObject private var vm: DiaryCheckViewModel
    
    // MARK: - Init
    init(
        diary: DiaryEntry,
        summary: DiarySummary,
        isDeleteSheetPresented: Binding<Bool>,
        container: DIContainer
    ) {
        self.diary = diary
        self.summary = summary
        self._isDeleteSheetPresented = isDeleteSheetPresented
        self.container = container
        
        _vm = StateObject(
            wrappedValue: DiaryCheckViewModel(
                diaryId: summary.diaryId,
                diaryService: container.useCaseService.diaryService,
                container: container
            )
        )
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color("brown01").ignoresSafeArea()
            
            VStack(spacing: 20) {
                headerBar()
                
                // 감정 아이콘 + 라벨
                emotionSection()
                
                // 카드
                diaryCard()
                
                Spacer(minLength: 12)
            }
        }
        // 삭제 확인 시트
        .overlay(alignment: .center) {
            if isDeleteSheetPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { isDeleteSheetPresented = false }
                
                DeleteConfirmationSheet(
                    isPresented: $isDeleteSheetPresented,
                    onDelete: {
                        vm.moveToTrash {
                            isDeleteSheetPresented = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
                .padding()
                .transition(.scale)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: isDeleteSheetPresented)
    }
    
    // MARK: - Header (뒤로가기 / 날짜 중앙 / 홈)
    @ViewBuilder
    private func headerBar() -> some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("green06"))
                        .frame(width: 24, height: 24)
                }

                Spacer()

                Text("2025.06.16 (월)") // ← 실제 날짜 포맷으로 치환 가능
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(Color("green06"))

                Spacer()

                Button {
                    // 홈 이동 로직
                    // container.navigationRouter.reset()
                    // container.navigationRouter.push(.baseTab)
                } label: {
                    Image("home_green")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 10)

            // 상단 바 하단 라인
            Rectangle()
                .fill(Color("green06").opacity(0.2))
                .frame(height: 1)
        }
    }
    
    // MARK: - Emotion section
    @ViewBuilder
    private func emotionSection() -> some View {
        VStack(spacing: 6) {
            Image("emotion_happy") // 감정에 맞게 바인딩 가능
                .resizable()
                .frame(width: 60, height: 60)

            Text("기쁨") // Emotion 매핑해서 넣기
                .font(.pretendardRegular(14))
                .foregroundColor(Color("green06"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    //MARK: - diaryCard
    @ViewBuilder
    private func diaryCard() -> some View {
        ZStack(alignment: .topTrailing) {            //  코너에 붙일 수 있게
            // 카드
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("white01"))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)

            // 내용
            VStack(alignment: .leading, spacing: 12) {
                // 제목
                if isEditing {
                    TextField("제목 입력", text: $vm.editedTitle)
                        .font(.pretendardSemiBold(18))
                        .foregroundColor(Color("black01"))
                        .padding(.top, 8)
                } else {
                    Text(vm.editedTitle)
                        .font(.pretendardSemiBold(18))
                        .foregroundColor(Color("black01"))
                        .padding(.top, 8)
                }

                // 이미지
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 215)
                    Image(systemName: "camera")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }

                // 본문
                Group {
                    if isEditing {
                        TextEditor(text: $vm.editedContent)
                            .font(.pretendardRegular(16))
                            .foregroundColor(Color("black01"))
                            .frame(height: 140)
                            .padding(.horizontal, 2)
                    } else {
                        Text(vm.editedContent)
                            .font(.pretendardRegular(16))
                            .foregroundColor(Color("black01"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                footerToolbar()
            }
            .padding(16)

            //  카드 우상단에 ‘딱’ 붙은 리본
            bookmarkRibbon(isOn: (summary.status == "SCRAP"))
                .padding(.top, 0)        // 카드 안쪽 여백 미세 조정
                .padding(.trailing, 20)   // 코너에 바짝
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .frame(height: 551)
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("black01").opacity(0.8))
                .frame(width: 160, height: 3)
                .offset(y: 10)
        }
    }
    // MARK: - Bookmark Ribbon
    @ViewBuilder
    private func bookmarkRibbon(isOn: Bool) -> some View {
        Button {
            vm.toggleScrap(diaryId: summary.diaryId)
        } label: {
            Image(isOn ? "bookmark_green" : "bookmark_empty")
                .resizable()
                .renderingMode(.original)
                .frame(width: 18, height: 24)
                // 터치 영역 넉넉하게
                .contentShape(Rectangle())
                .padding(6)
        }
    }
    
    // MARK: - Footer toolbar
    @ViewBuilder
    private func footerToolbar() -> some View {
        HStack(spacing: 16) {
            Spacer()
            // 수정 버튼
            Button {
                if isEditing {
                    let req = DiaryEditRequest(
                        emotion: vm.summary?.emotion ?? summary.emotion,
                        content: vm.editedContent,
                        sleepStartTime: nil,
                        sleepEndTime: nil,
                        diaryImgUrl: nil,
                        status: vm.summary?.status ?? summary.status,
                        isImgDeleted: false
                    )
                    vm.diaryEdit(diaryId: summary.diaryId, request: req)
                    isEditing = false
                } else {
                    isEditing = true
                }
            } label: {
                Image("edit_vector")
                    .resizable()
                    .frame(width: 40, height: 40)
            }

            // 저장(보관함) 버튼
            Button {
                isEditing = false
                vm.toggleTempStatus {
                    // 성공했을 때 추가 동작
                }
            } label: {
                // TEMP면 '보관됨(회색 아이콘)', 아니면 기본 아이콘
                let isTemp = (vm.summary?.status == "TEMP")
                Image(isTemp ? "storage_gray" : "storage_vector")
                    .resizable()
                    .frame(width: 40, height: 40)
            }

            // 삭제 버튼
            Button {
                isDeleteSheetPresented = true
            } label: {
                Image("delete_vector")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Preview
    struct DiaryCheckView_Previews: PreviewProvider {
        
        // 샘플 DiaryEntry (뷰 선행 렌더용 UI 모델)
        static let sampleEntry = DiaryEntry(
            id: 1,
            date: Date(),
            title: "행복했던 하루",
            content: "친구와 카페에서 즐거운 시간을 보냈다.",
            emotion: .HAPPY,
            isFavorite: false
        )
        
        // 샘플 DiarySummary (서버 DTO)
        static let sampleSummary = DiarySummary(
            diaryId: 1,
            diaryDate: "2025-06-16",
            title: "행복했던 하루",
            status: "NORMAL",     // "SCRAP"으로 바꾸면 북마크 아이콘 변경됨
            emotion: "HAPPY",
            content: "서버에서 내려온 본문 미리보기 텍스트"
        )
        
        struct Wrapper: View {
            @State private var isDeleteSheetPresented = false
            private let container = DIContainer() // 필요한 경우 목 서비스 주입
            
            var body: some View {
                NavigationStack {
                    DiaryCheckView(
                        diary: sampleEntry,
                        summary: sampleSummary,
                        isDeleteSheetPresented: $isDeleteSheetPresented,
                        container: container
                    )
                }
            }
        }
        
        // 삭제 시트가 열린 상태를 확인하고 싶다면 이 프리뷰도 함께 사용
        struct Wrapper_OpenSheet: View {
            @State private var isDeleteSheetPresented = true
            private let container = DIContainer()
            
            var body: some View {
                NavigationStack {
                    DiaryCheckView(
                        diary: sampleEntry,
                        summary: sampleSummary,
                        isDeleteSheetPresented: $isDeleteSheetPresented,
                        container: container
                    )
                }
            }
        }
        
        static var previews: some View {
            Group {
                Wrapper()
                    .previewDisplayName("기본")
                
                Wrapper_OpenSheet()
                    .previewDisplayName("삭제 시트 표시")
            }
            .background(Color("brown01"))
        }
    }
}
