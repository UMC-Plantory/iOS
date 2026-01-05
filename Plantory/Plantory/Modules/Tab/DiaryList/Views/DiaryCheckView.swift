//
//  DiaryCheckView.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//

import SwiftUI
import SwiftData
import Kingfisher

// 개별일기를 확인하는 View
struct DiaryCheckView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var container: DIContainer
    
    //MARK: - 상태
    @State var diaryId: Int
    
    @State var isDeleteSheetPresented: Bool = false
    
    // VM 은 init에서 주입
    @StateObject private var vm: DiaryCheckViewModel
    
    // MARK: - Init
     init(
       diaryId: Int,
       container: DIContainer
   ) {
       self.diaryId = diaryId

       _vm = StateObject(
           wrappedValue: DiaryCheckViewModel(
               diaryId: diaryId,
               container: container
           )
       )
   }
    
    // MARK: -Body
    var body: some View {
            ZStack {
                Color.homebackground.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 48) {
                        VStack(spacing: 24) {
                            // 뒤로가기, 날짜, 홈
                            headerView
                            
                            Divider()
                                .foregroundStyle(.gray04)
                                .frame(height: 0.6)
                                .padding(-18)
                        }
                        
                        // 감정 아이콘
                        emotionView
                        
                        // 일기 카드 내용
                        VStack(alignment: .leading, spacing: 16) {
                            // 제목
                            Text(vm.summary?.title ?? "제목 없음")
                                .font(.pretendardSemiBold(18))
                                .foregroundColor(.black01Dynamic)
                                .padding(.top, 16)
                            
                            DiaryCheckImageView()
                                .environmentObject(vm)
                            
                            // 본문
                            if vm.isEditing {
                                TextEditor(text: $vm.editedContent)
                                    .font(.pretendardRegular(16))
                                    .foregroundColor(.black01Dynamic)
                                    .frame(height: 140)
                                    .scrollContentBackground(.hidden)
                            } else {
                                ScrollView(.vertical) {
                                    Text(vm.editedContent)
                                        .font(.pretendardRegular(16))
                                        .foregroundColor(.black01Dynamic)
                                }
                                .scrollIndicators(.hidden)
                            }
                            
                            // 공유 아이콘들
                            HStack(spacing: 4) {
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        if vm.isEditing {
                                            Task {
                                                await vm.didTapEditing()
                                            }
                                            vm.isEditing = false
                                        } else {
                                            // 편집 모드로 진입
                                            vm.isEditing = true
                                        }
                                    }}, label: {
                                        Image("edit_vector")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(.black01Dynamic)
                                            .frame(width: 40, height: 40)
                                    })
                                
                                Button(action: {
                                    if !vm.isSaving {
                                        vm.toggleTempStatus() {
                                            withAnimation {
                                                vm.isEditing = false
                                                vm.isSaving = true
                                            }
                                        }
                                    }
                                }) {
                                    Image(vm.isSaving ? (colorScheme == .light ? "storage_gray": "storage_white") : "storage_vector")
                                        .resizable()
                                        .foregroundStyle(.black01Dynamic)
                                        .frame(width: 40, height: 40)
                                }
                                
                                Button(action: {
                                    isDeleteSheetPresented = true
                                }) {
                                    Image("delete_vector")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundStyle(.black01Dynamic)
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(.white01Dynamic, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(alignment: .topTrailing) {
                            Button(action: {
                                vm.toggleScrap()
                            }) {
                                Image(vm.summary?.status == "SCRAP" ? "bookmark_green" : "bookmark_empty")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(.green06Dynamic)
                                    .frame(width: 20, height: 23)
                            }
                            .padding(.trailing, 18)
                        }
                        .padding(.horizontal, 18)
                        
                        //AI 답장 모달
                        if (!vm.isEditing) {
                            DiaryReplyView()
                                .environmentObject(vm)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .animation(.easeInOut, value: isDeleteSheetPresented)
        .navigationBarBackButtonHidden()
        .task {
            UIApplication.shared.hideKeyboard()
            await vm.load()
            await vm.fetchNickname()
            vm.context = context
        }
        .popup(
            isPresented: $isDeleteSheetPresented,
            title: "일기를 삭제하시겠습니까?",
            message: "일기 삭제 시, 일기는 휴지통으로 이동하게 됩니다.",
            confirmTitle: "삭제하기",
            cancelTitle: "취소",
            onConfirm: {
                vm.moveToTrash {
                    container.navigationRouter.pop()
                }
            }
        )
        .toastView(toast: $vm.toast)
        .loadingIndicator(vm.isLoading)
    }
    
    // MARK: - 하위뷰들
        
    private var headerView: some View {
        HStack {
            Button(action: {
                container.navigationRouter.pop()
            }) {
                Image("leftChevron")
                    .renderingMode(.template)
                    .foregroundColor(.diaryCheckIcon)
            }
            
            Spacer()
            
            Text(formatToKoreanDate(vm.summary?.diaryDate) ?? "날짜 없음")
                .font(.pretendardSemiBold(20))
                .foregroundColor(.diaryCheckIcon)
            
            Spacer()
            
            Button(action: {
                container.navigationRouter.reset()
                container.selectedTab = .home
            }) {
                Image("home_green")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.diaryCheckIcon)
                    .frame(width: 24, height: 24)
                    .padding(.trailing,10)
            }
        }
        .padding()
    }
    
    private var emotionView: some View {
        VStack(spacing: 4) {
            if let summary = vm.summary {
                summary.emotion.image
                    .resizable()
                    .frame(width: 60, height: 60)
            } else {
                Circle()
                    .fill(.white)
                    .frame(width: 60, height: 60)
                    .overlay(
                        ProgressView()
                            .foregroundStyle(.green08)
                    )
            }
            
            Text(vm.summary?.emotion.displayName ?? "이미지 없음")
                .font(.pretendardSemiBold(14))
                .foregroundColor(.green04Dynamic)
        }
    }
    
    func formatToKoreanDate(_ input: String?) -> String? {
        guard let input = input else { return nil }
        
        // 1) 파서: "2025-07-29"
        let parser = DateFormatter()
        parser.calendar = Calendar(identifier: .gregorian)
        parser.locale = Locale(identifier: "en_US_POSIX")     // 숫자 파싱에 안전
        parser.timeZone = TimeZone(identifier: "Asia/Seoul")
        parser.dateFormat = "yyyy-MM-dd"

        guard let date = parser.date(from: input) else { return nil }

        // 2) 프린터: "2025.07.29 (화)"
        let printer = DateFormatter()
        printer.calendar = Calendar(identifier: .gregorian)
        printer.locale = Locale(identifier: "ko_KR")
        printer.timeZone = TimeZone(identifier: "Asia/Seoul")
        printer.dateFormat = "yyyy.MM.dd (E)"

        return printer.string(from: date)
    }
}
