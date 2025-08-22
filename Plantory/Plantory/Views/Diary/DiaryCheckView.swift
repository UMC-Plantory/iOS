//
//  DiaryCheckView.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//
import SwiftUI
import Combine

//개별일기를 확인하는 View
struct DiaryCheckView: View {
    @State private var isSaved = false //저장 상태변수
    @State private var isEditing = false // 수정 상태변수
    @Binding var isDeleteSheetPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    private let CARD_HEIGHT: CGFloat = 508 // 카드 고정 높이(피그마 기준)

    let container: DIContainer
    // VM 주입
    @StateObject private var vm: DiaryCheckViewModel
    
    // 현재 상세를 편하게 꺼내 쓰는 헬퍼
       private var detail: DiaryFetchResponse? { vm.detail }
    
    var emotion: Emotion {// 감정에 따른 이미지를 나타내기 위한 변수 emotion
        Emotion(rawValue: vm.detail?.emotion ?? "HAPPY") ?? .HAPPY
    }
    
//MARK: - 헬퍼 함수들
    /// 날짜 변환 헬퍼함수
    private var formattedDate: String {
        guard let diary = detail else { return "—" }
        return diary.diaryDate.toDate()?.toKoreanDiaryFormat() ?? diary.diaryDate
    }
    
    ///감정을 rawValue->displayName으로 바꿔주는 헬퍼 함수
    private var emotionDisplayName: String {
    let raw = detail?.emotion ?? ""
    let e = Emotion(rawValue: raw) ?? .HAPPY
    return e.displayName
}


    // MARK: - Init
    init(
        diaryId: Int,
        isDeleteSheetPresented: Binding<Bool>,
        container: DIContainer
    ) {
        self._isDeleteSheetPresented = isDeleteSheetPresented
        self.container = container
        
        _vm = StateObject(
            wrappedValue: DiaryCheckViewModel(
                diaryId: diaryId,
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
                
                Spacer()
                
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
                
                //diaryDate(YYYY-MM-DD) -> YYYY.MM.DD(EEEE)로 변환
                Text(formattedDate)
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(Color("green06"))
                
                Spacer()
                
                Button {
                    // 홈 이동 로직
                     container.navigationRouter.reset()
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
            Image(emotion.imageName) // 감정에 맞게 바인딩 가능
                .resizable()
                .frame(width: 60, height: 60)
            
            //감정에 맞게 바인딩(rawValue->displayName으로 매핑해서 출력됨)
            // 사용
            Text(emotionDisplayName)
                .font(.pretendardRegular(16))
                .foregroundColor(Color("green06"))
          
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    //MARK: - diaryCard
    @ViewBuilder
    private func diaryCard() -> some View {
        ZStack(alignment: .topTrailing) {
            // 카드
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("white01"))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            
            // 내용
            VStack(alignment: .leading, spacing: 20) {
                // 제목
                Group{
                    if isEditing {
                        TextField("제목 입력", text: $vm.editedTitle)
                            .font(.pretendardBold(20))
                            .foregroundColor(Color("black01"))
                            .padding(.leading, 20)
                       
                    } else {
                        Text(vm.editedTitle)
                            .font(.pretendardBold(20))
                            .foregroundColor(Color("black01"))
                            .lineLimit(1)
                           
                    }
                }
                .padding(.top, 10)
                .padding(.leading, 8)
                .frame(height: 24)  // 제목 높이 고정
               
                
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
                .padding(.leading, 8)
                
                Spacer()
                
                footerToolbar()
            }
            .padding(16)
            
            //  카드 우상단에 ‘딱’ 붙은 리본
            bookmarkRibbon(isOn: (detail?.status == "SCRAP"))
                .padding(.top, -4)        // 카드 안쪽 여백 미세 조정
                .padding(.trailing, 20)   // 코너에 바짝
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .frame(height: CARD_HEIGHT)
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
            guard let id = detail?.diaryId else { return }
                   vm.toggleScrap(diaryId: id)//북마크를 누르면 Scrap 상태로 토글됩니다.
        } label: {
            Image(isOn ? "bookmark_green" : "bookmark_empty")
                .resizable()
                .renderingMode(.original)
                .frame(width: 24, height: 31)
                .contentShape(Rectangle())
                .padding(6)
        }
    }
    
    // MARK: - Footer toolbar
    
    // 애니메이션 끄고 실행하는 헬퍼
    private func withoutAnimation(_ body: () -> Void) {
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t) { body() }
    }

    
    @ViewBuilder
    private func footerToolbar() -> some View {
        HStack(spacing: 16) {
            Spacer()
            // 수정 버튼
            toolButton(imageName: "edit_vector") {
                       withoutAnimation {
                           if isEditing {
                               let req = DiaryEditRequest(
                                   emotion: vm.detail?.emotion ?? detail?.emotion ?? "HAPPY",
                                   content: vm.editedContent,
                                   sleepStartTime: nil,
                                   sleepEndTime: nil,
                                   diaryImgUrl: nil,
                                   status: vm.detail?.status ?? detail?.status ?? "NORMAL",
                                   isImgDeleted: false
                               )
                               vm.diaryEdit(diaryId: detail?.diaryId ?? 0, request: req)
                               isEditing = false
                           } else {
                               isEditing = true
                           }
                       }
                   }
            
            // 저장(보관함) 버튼
            toolButton(imageName: (vm.detail?.status == "TEMP") ? "storage_gray" : "storage_vector") {
                       withoutAnimation {
                           isEditing = false
                           vm.toggleTempStatus { /* 성공시 추가 작업 */ }
                       }
                   }

            // 삭제 버튼
            toolButton(imageName: "delete_vector") {
                       withoutAnimation {
                           isDeleteSheetPresented = true
                }
            }
        }
        .frame(height: 48)              // 툴바 자체 높이 고정
         .buttonStyle(.plain)            // 기본 눌림 애니메이션 제거
         // 상태 변경시 레이아웃 애니메이션 완전 비활성화
         .animation(nil, value: isEditing)
         .animation(nil, value: vm.detail?.status ?? "")
    }
    
}

 
// 모든 툴바 아이콘 공통 버튼 (고정 크기 + 탭박스 균일)
@ViewBuilder
private func toolButton(imageName: String, action: @escaping () -> Void) -> some View {
    Button(action: { action() }) {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)     // 아이콘 자체 크기 고정
            .contentShape(Rectangle())
    }
    .frame(width: 48, height: 48, alignment: .center) // 버튼 박스 고정(여백 포함)
}
