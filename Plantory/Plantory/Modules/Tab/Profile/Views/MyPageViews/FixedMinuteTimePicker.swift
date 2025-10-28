import SwiftUI

struct WheelColumn<T: Hashable & CustomStringConvertible>: View {
    let items: [T]
    @Binding var selection: T
    var rowHeight: CGFloat = 44
    var width: CGFloat = 36
    var selectionBackground: Color = .clear
    var selectionLine: Color = .green04

    @State private var scrollID: T?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 선택 라인 + 흰 배경
                VStack(spacing: 0) {
                    Rectangle().fill(selectionLine).frame(height: 1)
                    Rectangle()
                        .fill(selectionBackground)        // ← 흰 배경
                        .frame(height: rowHeight - 2)
                    Rectangle().fill(selectionLine).frame(height: 1)
                }
                .frame(height: rowHeight)
                .frame(maxHeight: .infinity)
                .allowsHitTesting(false)

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // 위아래 버퍼(휠 느낌)
                            Color.clear.frame(height: (geo.size.height - rowHeight)/2)
                            ForEach(items, id: \.self) { it in
                                Text(it.description)
                                    .frame(height: rowHeight)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .id(it)
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            selection = it
                                            proxy.scrollTo(it, anchor: .center)
                                        }
                                    }
                            }
                            Color.clear.frame(height: (geo.size.height - rowHeight)/2)
                        }
                    }
                    .onChange(of: selection) { _, newValue in
                        withAnimation(.easeInOut) { proxy.scrollTo(newValue, anchor: .center) }
                    }
                    .onAppear {
                        proxy.scrollTo(selection, anchor: .center)
                    }
                    // 드래그 종료 시 가장 가까운 항목으로 스냅
                    .gesture(
                        DragGesture().onEnded { _ in
                            withAnimation(.easeInOut) { proxy.scrollTo(selection, anchor: .center) }
                        }
                    )
                }
            }
        }
        .frame(width: width, height: rowHeight * 3.5)
        .clipped()
    }
}

// MARK: - AM/PM 전용 타입
enum Meridiem: String, CaseIterable, Hashable, CustomStringConvertible {
    case am, pm
    var description: String { rawValue.uppercased() } // "AM", "PM"
}

extension Int: CustomStringConvertible { public var description: String { "\(self)" } }

struct FixedMinuteTimePicker_Custom: View {
    @Binding var hour: Int      // 1...12
    @Binding var isPM: Bool     // false=AM, true=PM

    var rowHeight: CGFloat = 44
    var columnSpacing: CGFloat = 32
    var lineColor: Color = .green

    private let hours = Array(1...12)

    var body: some View {
        // Bool ↔︎ Meridiem 바인딩 브리지
        let meridiemBinding = Binding<Meridiem>(
            get: { isPM ? .pm : .am },
            set: { isPM = ($0 == .pm) }
        )

        HStack {
            WheelColumn(items: hours, selection: $hour,
                        rowHeight: rowHeight, width: 56,
                        selectionBackground: .clear, selectionLine: lineColor)

            Spacer().frame(width: 8)
            Text(":").font(.pretendardRegular(18))
            Spacer().frame(width: 8)

            // 분은 00 고정
            ZStack {
                VStack(spacing: 0) {
                    Rectangle().fill(lineColor).frame(height: 1)
                    Rectangle().fill(.clear).frame(height: rowHeight - 2)
                    Rectangle().fill(lineColor).frame(height: 1)
                }
                .frame(height: rowHeight * 3.5)
                Text("00")
                    .font(.pretendardRegular(18))
                    .frame(width: 56, height: rowHeight * 3.5)
            }
            .frame(width: 56, height: rowHeight * 3.5)

            Spacer().frame(width: 16)

            // ▼ 여기만 변경: Bool 대신 Meridiem을 쓰되, Binding으로 연결
            WheelColumn(items: Meridiem.allCases, selection: meridiemBinding,
                        rowHeight: rowHeight, width: 64,
                        selectionBackground: .clear, selectionLine: lineColor)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

// MARK: - Demo (선택값 보여주기 추가)
struct Demo: View {
    @State private var hour = 11
    @State private var isPM = true

    var body: some View {
        VStack(spacing: 12) {
            FixedMinuteTimePicker_Custom(hour: $hour, isPM: $isPM,
                                         rowHeight: 52, columnSpacing: 40, lineColor: .green04)
            // 현재 선택된 시간 확인용 텍스트 (스타일/여백 변경 없음)
            Text("선택: \(hour):00 \(isPM ? "PM" : "AM")")
                .font(.pretendardRegular(16))
        }
    }
}

#Preview { Demo() }
