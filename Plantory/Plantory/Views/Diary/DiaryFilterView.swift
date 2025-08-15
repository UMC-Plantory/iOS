//
//  DiaryFilterView.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//
import SwiftUI

//필터시트가 올라온 화면(View) 입니다.
struct DiaryFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject  var viewModel : DiaryFilterViewModel
    @State private var selectedSort: DiarySort = .latest
    @State private var selectedYear: Int = 2025
    @State private var selectedMonths: Set<Int>
    @State private var selectedEmotions: Set<Emotion> = [.all]
    
    private let currentDate = Date()
    private let calendar = Calendar.current
    
    init(/// DIContainer을 주입받아 초기화
        ///유저가 초기값 설정할 수 있도록 근데 지금은 프리뷰에 파라미터를 넘겨주도록
           container: DIContainer = .init(),          // 프리뷰/테스트용 기본값
           initialSelectedMonths: Set<Int> = []       // 초기 선택 월
       ) {
           _selectedMonths = State(initialValue: initialSelectedMonths)
           _viewModel      = StateObject(wrappedValue: DiaryFilterViewModel(container: container))
       }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 상단 바
            HStack {
                Text("필터")
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(Color("black01"))
                Spacer()
            }
            .padding(.top, 32)
            .padding(.leading, 20)
            
            Divider()
            
            // 나열 방식 선택
            VStack(alignment: .leading, spacing: 20) {
                Text("나열")
                    .font(.pretendardSemiBold(18))
                    .foregroundColor(Color("black01"))
                
                
                HStack(spacing: 32) {
                    //커스텀 버튼
                    OrderButton(title: "최신순", isSelected: selectedSort == .latest) {
                        selectedSort = .latest
                    }
                    OrderButton(title: "오래된 순", isSelected: selectedSort == .oldest) {
                        selectedSort = .oldest
                    }
                }
            }
            .padding(.leading,20)
            
            Divider()
            
            // 범위 선택
            VStack(alignment: .center, spacing: 12) {
                HStack {
                    Text("범위")
                        .font(.pretendardSemiBold(16))
                    Button(action: {
                        selectedMonths.removeAll()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)// ← 여기 추가!
                .padding(.leading,10)
                
                HStack {
                    Button(action: { selectedYear -= 1 }) {
                        Image(systemName: "chevron.left")
                    }
                    Text("\(String(selectedYear))년")
                        .font(.pretendardRegular(16))
                    
                    Button(action: { selectedYear += 1 }) {
                        Image(systemName: "chevron.right")
                    }
                }
                
                .foregroundColor(Color("black01"))
                
                ZStack {
                    // 연결선
                    HStack(spacing: 0) {
                        ForEach(1..<12) { month in
                            let isBetween = selectedMonths.contains(month) && selectedMonths.contains(month + 1)
                            Rectangle()
                                .fill(isBetween ? Color("green04") : Color("gray06"))
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                     .padding(.horizontal, 12) // 원보다 살짝 안쪽
                     .offset(y:-10)//선을 가운데로 정렬시켜주기

                    //월 원형 선택
                    HStack(spacing: 0) {
                        ForEach(1...12, id: \.self) { month in
                            let isSelected = selectedMonths.contains(month)
                            let isFuture = viewModel.isFutureMonth(year: selectedYear, month: month)
                            let backgroundColor: Color = isSelected ? Color("green04") : (isFuture ? Color("gray03") : Color("white01"))
                            let borderColor: Color = isSelected ? Color("green06") : Color("gray04")
                            let textColor: Color = isSelected ? Color("green06") : (isFuture ? Color("gray06") : Color("black01"))

                            VStack(spacing: 4) {
                                Circle()
                                    .strokeBorder(borderColor, lineWidth: 1)
                                    .background(Circle().fill(backgroundColor))
                                    .frame(width: 20, height: 20)
                                    .onTapGesture {
                                        if isFuture { return }
                                        if isSelected {
                                            selectedMonths.remove(month)
                                        } else {
                                            selectedMonths.insert(month)
                                        }
                                    }

                                Text("\(month)")
                                    .font(.pretendardRegular(14))
                                    .foregroundColor(textColor)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal)
                
                Divider()
                
                // 감정 선택
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("감정")
                            .font(.pretendardSemiBold(16))
                            
                        Button(action: {
                            selectedEmotions = [.all]
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.leading, 4)
                    .padding(.top,10)
                    
                    HStack(spacing: 12) {
                        ForEach(Emotion.allCases, id: \ .self) { emotion in
                            EmotionTag(emotion: emotion, isSelected: selectedEmotions.contains(emotion)) {
                                if emotion == .all {
                                    selectedEmotions = [.all]
                                } else {
                                    selectedEmotions.remove(.all)
                                    if selectedEmotions.contains(emotion) {
                                        selectedEmotions.remove(emotion)
                                    } else {
                                        selectedEmotions.insert(emotion)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top,10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        // 필터 적용
                        let dto = DiaryFilterRequest(
                            sort: selectedSort,  // DiarySort 타입
                                from: String(format: "%04d-%02d", selectedYear, selectedMonths.min() ?? 1),
                                to: String(format: "%04d-%02d", selectedYear, selectedMonths.max() ?? 12),
                            emotion: selectedEmotions.first ?? .all, // Emotion 타입
                                cursor: nil,
                                size: 20
                           )

                           viewModel.fetchFilteredDiaries(dto) 
                        dismiss()
                    }) {
                        Text("적용하기")
                            .font(.pretendardSemiBold(16))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 24)
                            .background(Color("green06"))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    .padding(.trailing, 22)
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 16)
        }
    }
}



#Preview {
    DiaryFilterView(initialSelectedMonths: [4, 5])
}
