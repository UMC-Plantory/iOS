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
    @Environment(\.presentationMode) var presentationMode
    private let CARD_HEIGHT: CGFloat = 508 // 카드 고정 높이(피그마 기준)
    
    
    //MARK: -입력 파라미터(외부에서 값을 주입받아야함
    let summary: DiarySummary
    let diary: DiaryEntry
    let container: DIContainer
    var emotion: Emotion {
        Emotion(rawValue: summary.emotion) ?? .HAPPY
    } // 감정에 따른 이미지를 나타내기 위한 변수 emotion
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
                if let date = summary.diaryDate.toDate() {
                    Text(date.toKoreanDiaryFormat())
                        .font(.pretendardSemiBold(20))
                        .foregroundColor(Color("green06"))
                } else {
                    // 변환 실패하면 원본 문자열 그대로 표시
                    Text(summary.diaryDate)
                        .font(.pretendardSemiBold(20))
                        .foregroundColor(Color("green06"))
                }
                
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
            
            //감정에 맞게 바인딩
            Text((Emotion(rawValue: summary.emotion) ?? .HAPPY).displayName)
                .font(.pretendardRegular(16))
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
                Group{
                    if isEditing {
                        TextField("제목 입력", text: $vm.editedTitle)
                            .font(.pretendardSemiBold(18))
                            .foregroundColor(Color("black01"))
                            .padding(.leading, 20)
                       
                    } else {
                        Text(vm.editedTitle)
                            .font(.pretendardSemiBold(18))
                            .foregroundColor(Color("black01"))
                            .lineLimit(1)
                           
                    }
                }
                .padding(.top, 8)
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
                Spacer()
                
                footerToolbar()
            }
            .padding(16)
            
            //  카드 우상단에 ‘딱’ 붙은 리본
            bookmarkRibbon(isOn: (summary.status == "SCRAP"))
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
            vm.toggleScrap(diaryId: summary.diaryId)
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
                       }
                   }
            
            // 저장(보관함) 버튼
            toolButton(imageName: (vm.summary?.status == "TEMP") ? "storage_gray" : "storage_vector") {
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
         .animation(nil, value: vm.summary?.status ?? "")
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
   
#if DEBUG

/// 프리뷰/개발용 Mock
final class PreviewDiaryService: DiaryServiceProtocol {

    // MARK: - 단일 일기 조회 (GET /diaries/{id})
    func fetchDiary(id: Int) -> AnyPublisher<DiaryFetchResponse, APIError> {
        Just(
     
            DiaryFetchResponse(
                diaryId: id,
                diaryDate: "2022-09-05",
                emotion: "HAPPY",
                title: "미리보기 제목",
                content: "미리보기 본문",
                diaryImgUrl: "https://example.com/image.jpg",
                status: "NORMAL"
            )
        )
        .setFailureType(to: APIError.self)
        .eraseToAnyPublisher()
    }

    // MARK: - 일기 목록 필터 조회 (GET /diaries/filter?...)
    func fetchFilteredDiaries(_ req: DiaryFilterRequest) -> AnyPublisher<DiaryFilterResult, APIError> {
        Just(
            DiaryFilterResult(
                diaries: [
                    DiarySummary(
                        diaryId: 1,
                        diaryDate: "2025-06-16",
                        title: "행복했던 하루",
                        status: "NORMAL",
                        emotion: "HAPPY",
                        content: "프리뷰 더미"
                    ),
                    DiarySummary(
                        diaryId: 2,
                        diaryDate: "2025-06-17",
                        title: "조용한 하루",
                        status: "SCRAP",
                        emotion: "SAD",
                        content: "프리뷰 더미"
                    )
                ],
                hasNext: false,
                nextCursor: nil
            )
        )
        .setFailureType(to: APIError.self)
        .eraseToAnyPublisher()
    }

    // MARK: - 일기 검색 (GET /diaries/search?...)
    func searchDiary(_ req: DiarySearchRequest) -> AnyPublisher<DiarySearchResult, APIError> {
        Just(
            DiarySearchResult(
                diaries: [
                    DiarySummary(
                        diaryId: 3,
                        diaryDate: "2025-06-18",
                        title: "검색 결과",
                        status: "NORMAL",
                        emotion: "ANGRY",
                        content: "프리뷰 더미"
                    )
                ],
                hasNext: false,
                nextCursor: nil,
                total: 10
            )
        )
        .setFailureType(to: APIError.self)
        .eraseToAnyPublisher()
    }

    // MARK: - 일기 수정 (PATCH /diaries/{id})
    func editDiary(id: Int, data: DiaryEditRequest) -> AnyPublisher<DiaryDetail, APIError> {
        Just(
            DiaryDetail(
                diaryId: id,
                diaryDate: "2022-09-05",
                emotion: data.emotion,                // 요청값 반영
                title: "미리보기 제목(수정됨)",
                content: data.content,                // 요청값 반영
                diaryImgUrl: "https://example.com/image-edited.jpg",
                status: data.status ?? "NORMAL"       // 없으면 NORMAL
            )
        )
        .setFailureType(to: APIError.self)
        .eraseToAnyPublisher()
    }

    // MARK: - 휴지통 이동 (PATCH /diaries/waste-status)
    func moveToTrash(ids: [Int]) -> AnyPublisher<EmptyResponse, APIError> {
        Just(EmptyResponse())
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }

    // MARK: - 영구 삭제 (DELETE /diaries)
    func deletePermanently(ids: [Int]) -> AnyPublisher<EmptyResponse, APIError> {
        Just(EmptyResponse())
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }

    // MARK: - 스크랩 On/Off (PATCH /diaries/{id}/scrap-status/*)
    func scrapOn(id: Int) -> AnyPublisher<EmptyResponse, APIError> {
        Just(EmptyResponse())
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }

    func scrapOff(id: Int) -> AnyPublisher<EmptyResponse, APIError> {
        Just(EmptyResponse())
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }

    // MARK: - 임시보관/복원 토글 (PATCH /diaries/temp-status)
    func updateTempStatus(ids: [Int]) -> AnyPublisher<EmptyResponse, APIError> {
        Just(EmptyResponse())
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}
#endif


struct DiaryCheckView_Previews: PreviewProvider {

    // 샘플 DiaryEntry (뷰 렌더용 모델)
    static let sampleEntry = DiaryEntry(
        id: 1,
        date: Date(),
        title: "행복했던 하루",
        content: "친구와 카페에서 즐거운 시간을 보냈다.",
        emotion: .HAPPY,
        isScrapped: false
    )

    // 샘플 DiarySummary (서버 DTO)
    static let sampleSummary = DiarySummary(
        diaryId: 1,
        diaryDate: "2025-06-16",
        title: "행복했던 하루",
        status: "NORMAL",
        emotion: "HAPPY",
        content: "서버에서 내려온 본문 미리보기 텍스트"
    )

    struct Wrapper: View {
        @State private var isDeleteSheetPresented = false

        // 미리보기용 DIContainer (내부에서 PreviewDiaryService 사용하도록)
        private let container: DIContainer = {
            let c = DIContainer()
            // 필요 시 mock 서비스 주입 (예시)
            // c.useCaseService = UseCaseService(diaryService: PreviewDiaryService(), ...)
            return c
        }()

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
        Wrapper()
            .background(Color("brown01"))
    }
}
