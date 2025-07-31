//
//  DiaryFilterView.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//
import SwiftUI

struct DiaryFilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedOrder: Order = .latest
    @State private var selectedYear: Int = 2025
    @State private var selectedMonths: Set<Int>
    @State private var selectedEmotions: Set<Emotion> = [.all]
    
    private let currentDate = Date()
    private let calendar = Calendar.current
    //private var isBetween = true //@State는 뷰의 UI상태 저장용인데 isBetween은 그때그때 계산되는 일시적인 값이므로 이런 선언이 불필요(트러블슈팅에)
    
    //유저가 초기값 설정할 수 있도록 근데 지금은 프리뷰에 파라미터를 넘겨주도록
    init(initialSelectedMonths: Set<Int>) {
            _selectedMonths = State(initialValue: initialSelectedMonths)
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
                    OrderButton(title: "최신순", isSelected: selectedOrder == .latest) {
                        selectedOrder = .latest
                    }
                    OrderButton(title: "오래된 순", isSelected: selectedOrder == .oldest) {
                        selectedOrder = .oldest
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
                    Text("\(String(selectedYear))년")                        .font(.pretendardRegular(16))
                    
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
                            let isFuture = isFutureMonth(year: selectedYear, month: month)

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
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        // 필터 적용
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
    
    //날짜 비교, 현재 날짜보다 미래는 회색으로 처리
    private func isFutureMonth(year: Int, month: Int) -> Bool{
        guard let compareDate = calendar.date(from: DateComponents(year: year, month: month)) else {
            return false
        }
        return compareDate > currentDate
    }
    
}
//선택된 버튼에 초록색 채워넣는 부분
struct OrderButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(isSelected ? "radio_green" : "radio_gray")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? Color("green04") : .gray)

                Text(title)
                    .foregroundColor(Color("black01"))
                    .font(.pretendardRegular(16))
            }
        }
    }
}

struct EmotionTag: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(emotion.rawValue)
            .font(.pretendardRegular(14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color("green04") : Color.white)
            .foregroundColor(isSelected ? .white : .gray)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(20)
            .onTapGesture {
                action()
            }
    }
}

#Preview {
    DiaryFilterView(initialSelectedMonths: [4, 5])
}
