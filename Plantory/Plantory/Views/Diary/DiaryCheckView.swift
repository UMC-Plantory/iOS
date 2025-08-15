//
//  DiaryCheckView.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//
import SwiftUI

//개별일기를 확인하는 View
struct DiaryCheckView: View {
    
    @EnvironmentObject var container: DIContainer
    @State private var isSaved = false //저장 상태변수
    @State private var isEditing = false // 수정 상태변수
    @Environment(\.presentationMode) var presentationMode
    
    //MARK: -입력 파라미터(외부에서 값을 주입받아야함
    let summary: DiarySummary
    let diary: DiaryEntry
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

           _vm = StateObject(
               wrappedValue: DiaryCheckViewModel(
                   diaryId: summary.diaryId,  // 또는 diary.id
                   diaryService: container.useCaseService.diaryService
               )
           )
       }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color("brown01").ignoresSafeArea()
            // 기존 본문 (배경 + 일기 내용)
            VStack(alignment: .leading, spacing: 10) {
                
                // HStack: 뒤로가기, 날짜, 홈
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("green06"))
                        
                    }
                    
                    Spacer()
                    
                    Text("2025.06.16 (월)")
                        .font(.pretendardSemiBold(20))
                        .foregroundColor(Color("green06"))
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image("home_green")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.trailing,10)
                    }
                }
                .padding()
                
                // 감정 아이콘
                VStack(spacing: 8) {
                    Image("emotion_happy")
                        .resizable()
                        .frame(width: 60, height: 60)
                    
                    Text("기쁨")
                        .font(.pretendardRegular(14))
                        .foregroundColor(Color("gray08"))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 47)
                .padding(.top,25)
                
                // 일기 카드 내용
                VStack(alignment: .leading, spacing: 0) {
                    // 제목 + 북마크
                    HStack {
                        if isEditing {
                            TextField("제목 입력", text: $vm.editedTitle)
                                .font(.pretendardSemiBold(18))
                                .foregroundColor(Color("black01"))
                                .padding(.top, 20)
                        } else {
                            Text(vm.editedTitle)
                                .font(.pretendardSemiBold(18))
                                .foregroundColor(Color("black01"))
                                .padding(.top, 20)
                        }
                        Spacer()
                        
                        Button(action: {
                            vm.toggleScrap(diaryId: summary.diaryId)
                        }) {
                            Image(summary.status == "SCRAP" ? "bookmark_green" : "bookmark_empty")
                                .resizable()
                                .frame(width: 20, height: 23)
                                .padding([.top, .trailing], -35)
                        }
                        
                        // 이미지 placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 321, height: 215)
                            Image(systemName: "camera")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                        
                        // 본문
                        if isEditing {
                            TextEditor(text: $vm.editedContent)
                                .font(.pretendardRegular(16))
                                .foregroundColor(Color("black01"))
                                .frame(height: 140)
                                .padding(.horizontal, 4)
                                .padding(.top,5)
                        } else {
                            Text(vm.editedContent)
                                .font(.pretendardRegular(16))
                                .foregroundColor(Color("black01"))
                                .padding(.top, 5)
                        }
                        
                        // 공유 아이콘들
                        HStack(spacing: 4) {
                            Spacer()
                            Button {
                                if isEditing {
                                    // 저장 로직
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
                                    // 편집 모드로 진입
                                    isEditing = true
                                }
                            } label: {
                                Image("edit_vector")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            
                            Button(action: {
                                isEditing = false
                                isSaved = true
                            }) {
                                Image(isSaved ? "storage_gray" : "storage_vector")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            Button(action: {
                                isDeleteSheetPresented = true
                            }) {
                                Image("delete_vector")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color("white01"))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .frame(width: 358, height: 536)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                }
                .animation(.easeInOut, value: isDeleteSheetPresented)
                
                
                if isDeleteSheetPresented {
                    ZStack {
                        // 어두운 배경 (탭하면 닫기)
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture { isDeleteSheetPresented = false }

                        // 중앙 모달 시트
                        DeleteConfirmationSheet(
                            isPresented: $isDeleteSheetPresented,
                            onDelete: {
                                // 삭제(=휴지통 이동) 실행
                                vm.moveToTrash {
                                    // 성공 콜백: 시트 닫고 화면도 필요하면 닫기
                                    isDeleteSheetPresented = false
                                    presentationMode.wrappedValue.dismiss()
                                    // 또는 네비게이션 라우터 쓰면:
                                    // container.navigationRouter.pop()
                                }
                            }
                        )
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale)
                    .zIndex(1)
                }
            }
            
        }
    }
    
    // MARK: - Preview
    #Preview {
        // 미리보기용 DIContainer
        let previewContainer = DIContainer()
        

        // mock
        let mockDiary = DiaryEntry(
            id: 1,
            date: Date(),
            title: "프리뷰용 제목",
            content: "이건 프리뷰용 내용입니다.",
            emotion: .HAPPY,
            isFavorite: false
        )
        
        let mockSummary = DiarySummary(
            diaryId: 1,
            diaryDate: "2025-06-16",
            title: "프리뷰용 제목",
            status: "NORMAL",   // 순서 맞춤
            emotion: "HAPPY",   // 순서 맞춤
            content: "내용"     // 마지막에 content
        )
        
      DiaryCheckView(
            diary: mockDiary,
            summary: mockSummary,
            isDeleteSheetPresented: .constant(false),
            container: previewContainer
        )
        .environmentObject(previewContainer)

        private let mockDiary = DiaryEntry(
                id: 1,
                date: Date(),
                title: "프리뷰용 제목",
                content: "이건 프리뷰용 내용입니다.",
                emotion: .HAPPY,
                isFavorite: false
            )

        var body: some View {
            DiaryCheckView(
                diary: mockDiary,
                isDeleteSheetPresented: $isDeleteSheetPresented)
        }

    }
}
