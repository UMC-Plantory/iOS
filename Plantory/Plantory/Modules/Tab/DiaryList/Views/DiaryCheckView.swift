//
//  DiaryCheckView.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//

import SwiftUI
import Kingfisher

//ai 답장 생성 상태
enum ReplyState {
    case loading //로딩중
    case arrived //ai답장 생성 완료
    case complete //ai답장 확인
}

// 개별일기를 확인하는 View
struct DiaryCheckView: View {
    
    @EnvironmentObject var container: DIContainer
    
    //MARK: - 상태
    @State var diaryId: Int
    
    @State var isDeleteSheetPresented: Bool = false
    
    // VM 은 init에서 주입
    @StateObject private var vm: DiaryCheckViewModel
    
    @State private var state: ReplyState = .loading
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
                Color.brown01.ignoresSafeArea()
                
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
                            .foregroundColor(.black01)
                            .padding(.top, 20)
                        
                        DiaryCheckImageView()
                            .environmentObject(vm)
                        
                        // 본문
                        if vm.isEditing {
                            TextEditor(text: $vm.editedContent)
                                .font(.pretendardRegular(16))
                                .foregroundColor(.black01)
                                .frame(height: 140)
                        } else {
                            ScrollView(.vertical) {
                                Text(vm.editedContent)
                                    .font(.pretendardRegular(16))
                                    .foregroundColor(.black01)
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
                                }
                            }) {
                                Image("edit_vector")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                                  
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
                                Image(vm.isSaving ? "storage_gray" : "storage_vector")
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
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(.white01, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            vm.toggleScrap()
                        }) {
                            Image(vm.summary?.status == "SCRAP" ? "bookmark_green" : "bookmark_empty")
                                .resizable()
                                .frame(width: 20, height: 23)
                        }
                        .padding(.trailing, 18)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 28)
                        
                        
                        //AI 답장 모달
                        VStack {
                               if state == .loading {
                                   LoadingCardView()
                               } else if state == .arrived {
                                   ArrivedCardView(onConfirm: {
                                       state = .complete
                                   })
                               } else if state == .complete {
                                   CompleteCardView()
                               }
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
    
    
    
    // MARK: -하위뷰들
    private var headerView: some View {
        HStack {
            Button(action: {
                container.navigationRouter.pop()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.green06)
                
            }
            
            Spacer()
            
            Text(formatToKoreanDate(vm.summary?.diaryDate) ?? "날짜 없음")
                .font(.pretendardSemiBold(20))
                .foregroundColor(.green06)
            
            Spacer()
            
            Button(action: {
                container.navigationRouter.reset()
                container.navigationRouter.push(.baseTab)
                container.selectedTab = .home
            }) {
                Image("home_green")
                    .resizable()
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
                    .fill(.white01)
                    .frame(width: 60, height: 60)
                    .overlay(
                        ProgressView()
                            .foregroundStyle(.green08)
                    )
            }
            
            Text(vm.summary?.emotion.displayName ?? "이미지 없음")
                .font(.pretendardSemiBold(14))
                .foregroundColor(.green04)
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



 // MARK: -모달 뷰
///AI 답장 로딩 중
private struct LoadingCardView: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 12) {
            LoadingDotsView()
                .padding(.bottom, 10)
    
            Text("AI가 답장을 생성하고 있습니다.")
                .font(.pretendardSemiBold(18))
                .foregroundStyle(.black01)
            
            Text("잠시만 기다려주세요.")
                .font(.pretendardRegular(14))
                .foregroundStyle(.gray09)
        }
        .onAppear { animate = true }
        .frame(width: 358, height: 176)
        .background(Color.white01)
        .cornerRadius(10)
    }
       
    
}

///AI 답장 도착
private struct ArrivedCardView: View {
    var onConfirm: () -> Void   // 버튼 액션을 외부에서 주입
    
    var body: some View {
        VStack(spacing: 16) {
            // 아이콘
            Image("envelope_closed")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 48)
            
            // 텍스트
            Text("AI의 답장이 도착했습니다.")
                .font(.pretendardBold(18))

            // 버튼
            Button {
                onConfirm() //버튼 클릭
            } label: {
                Text("답장 확인하기")
                    .font(.pretendardRegular(14))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Color.green06)
                    .foregroundStyle(.white01)
                    .cornerRadius(5)
            }
        }
        .padding()
        .frame(width:358, height: 176)
        .background(Color.white01)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

///AI답장 확인
private struct CompleteCardView: View {
    var nickname: String = "유엠씨"
    var reply: String = "답장 내용 …… 어쩌구 저쩌구 오늘은 점심에 유엠이랑 밥을 먹었는데 너무 맛있었다. 저녁에는 친구 집들이를 갔다. 선물로 유리컵과 접시 세트를 사 갔는데 마침 집에 이러한 것들이 필요했다고 해서 너무 다행이었다."

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image( "envelope_open")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 48)
            
            // 상단 아이콘 + 제목
            HStack(spacing: 8) {
                    Text("\(nickname)")
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(.green05)
                + Text("에게 드리는 답장")
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(.black01)
        
            }

            // 본문
            Text(reply)
                .font(.pretendardRegular(16))
                .foregroundStyle(.gray11)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.white01)
        .frame(width: 358, height: 262)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

//LoadingCardView의 컴포넌트
private struct LoadingDotsView: View {
    @State private var animate = false
    let totalDots = 6
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalDots, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "7B9349"))
                    .frame(width: 14, height: 14)
                    .offset(y: (i == 4 && animate) ? -8 : 0) // 5번째 원만 위로 점프
                    .opacity(animate ? 1.0 : 0.3)
                    .offset(y: animate ? -10 : 0) // 위로 솟아오르기
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(i) * 0.15), // 점차적으로 딜레이
                        value: animate
                                        )
            }
        }
        .onAppear {
            animate = true
        }
    }
}
