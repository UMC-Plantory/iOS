//
//  MonthYearhPickerView.swift
//  Plantory
//
//  Created by 김지우 on 8/5/25.
//

import SwiftUI

// MARK: - PreferenceKey
private struct YearButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

// MARK: - 드롭다운 리스트 (내부 스크롤 고정 높이)
private struct YearDropdown: View {
    let years: [Int]
    let selected: Int
    let onSelect: (Int) -> Void

    private let dropdownWidth: CGFloat = 300
    private let dropdownHeight: CGFloat = 320
    private let rowHeight: CGFloat = 56

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(years, id: \.self) { y in
                        Button {
                            onSelect(y)
                        } label: {
                            HStack {
                                // 쉼표 방지
                                Text(verbatim: "\(y)년")
                                    .font(.pretendardRegular(14))
                                    .foregroundColor(.white01)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .frame(height: rowHeight)
                            .background(y == selected ? Color.white01.opacity(0.08) : .clear)
                        }
                        .id(y)

                        Divider().background(Color.white01.opacity(0.5))
                    }
                }
            }
            .frame(height: dropdownHeight) // 내부 스크롤
            .onAppear {
                DispatchQueue.main.async {
                    proxy.scrollTo(selected, anchor: .center)
                }
            }
        }
        .frame(width: dropdownWidth)
        .background(
            LinearGradient(colors: [.gray09.opacity(0.95), .gray09.opacity(0.85)],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
    }
}

// MARK: - 메인 뷰
struct MonthYearPickerView: View {
    // HomeView에서 사용
    let initialYear: Int
    let initialMonth: Int
    let onApply: (Int, Int) -> Void

    // 적용 전 초안(draft)
    @State private var draftYear: Int
    @State private var draftMonth: Int

    // 드롭다운 상태/위치
    @State private var isYearMenuOpen: Bool = false
    @State private var yearButtonFrameGlobal: CGRect = .zero

    // 연도 소스: 과거 60년 ~ 미래 5년, 최신이 위로 오도록
    private let years: [Int] = {
        let now = Calendar.current.component(.year, from: Date())
        let minY = now - 60
        let maxY = now + 5
        return Array(minY...maxY).reversed()
    }()

    init(initialYear: Int, initialMonth: Int, onApply: @escaping (Int, Int) -> Void) {
        self.initialYear = initialYear
        self.initialMonth = initialMonth
        self.onApply = onApply
        _draftYear = State(initialValue: initialYear)
        _draftMonth = State(initialValue: initialMonth)
    }

    var body: some View {
        // 루트는 전체 화면 사이즈를 차지해 ‘절대 좌표’ 배치 가능
        ZStack(alignment: .topLeading) {
            // 바깥 차단 레이어: 탭/드래그 모두 흡수 → 모달 고정
            if isYearMenuOpen {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.18)) { isYearMenuOpen = false }
                    }
                    .zIndex(1)
            }

            // 모달 카드 (항상 고정되게끔)
            VStack(spacing: 18) {
                HStack {
                    // 연도 버튼(검정 텍스트)
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { isYearMenuOpen.toggle() }
                    } label: {
                        HStack(spacing: 8) {
                            // 쉼표 방지
                            Text(verbatim: "\(draftYear)년")
                                .font(.pretendardSemiBold(20))
                                .foregroundColor(.black01)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black01)
                                .rotationEffect(.degrees(isYearMenuOpen ? 180 : 0))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray05, lineWidth: 1)
                        )
                    }
                    // 전역 좌표로 버튼 프레임 측정 → 드롭다운 배치
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: YearButtonFrameKey.self,
                                                   value: geo.frame(in: .global))
                        }
                    )

                    Spacer()

                    // 적용 버튼: 눌러야만 외부에 적용
                    Button {
                        onApply(draftYear, draftMonth)
                    } label: {
                        Text("적용")
                            .font(.pretendardSemiBold(18))
                            .foregroundColor(.green05)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green05, lineWidth: 1)
                            )
                    }
                }

                // 월 선택(하이라이트만 변경)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4),
                          spacing: 16) {
                    ForEach(1...12, id: \.self) { m in
                        Button { draftMonth = m } label: {
                            Text("\(m)월")
                                .font(.pretendardRegular(18))
                                .foregroundColor(.white01)
                                .frame(width: 72, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(draftMonth == m ? .green04 : .gray05)
                                )
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(20)
            // clipShape 쓰면 드롭다운이 잘리니 background로 둥근 모양만 적용
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white01)
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
            )
            .frame(width: 336)
            .onPreferenceChange(YearButtonFrameKey.self) { yearButtonFrameGlobal = $0 }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 중앙 고정

            // 드롭다운: 버튼 전역 프레임 기준으로 절대 배치
            if isYearMenuOpen {
                YearDropdown(
                    years: years,
                    selected: draftYear,
                    onSelect: { y in
                        draftYear = y
                        withAnimation(.easeInOut(duration: 0.18)) { isYearMenuOpen = false }
                    }
                )
                .offset(x: yearButtonFrameGlobal.minX,
                        y: yearButtonFrameGlobal.maxY + 8) // 버튼 바로 아래 + 간격 8
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 전체 공간 사용
    }
}
