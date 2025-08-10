import SwiftUI

/// 드롭다운 형태의 입력 필드
/// InputField 디자인을 참고하여 커스텀 Dropdown UI를 구현합니다.
public struct DropdownField: View {
    let title: String
    let placeholder: String
    let options: [String]
    @Binding var selection: String
    @Binding var state: FieldState
    @State private var isExpanded: Bool = false

    public init(
        title: String,
        placeholder: String = "선택하세요",
        options: [String],
        selection: Binding<String>,
        state: Binding<FieldState>
    ) {
        self.title = title
        self.placeholder = placeholder
        self.options = options
        self._selection = selection
        self._state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.pretendardRegular(14))

            // Main selection button
            Button(action: toggleDropdown) {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .font(.pretendardRegular(14))
                        .foregroundColor(selection.isEmpty ? Color.gray06 : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(isExpanded ? Color.green06 : state.borderColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isExpanded ? Color.green06 : state.borderColor, lineWidth: 1)
                )
            }
            // Dropdown list overlay - does not affect layout
            .overlay(
                Group {
                    if isExpanded {
                        VStack(spacing: 0) {
                            ForEach(options, id: \.self) { option in
                                Button(action: { select(option) }) {
                                    HStack {
                                        Text(option)
                                            .font(.pretendardRegular(14))
                                            .foregroundColor(option == selection ? Color.green06 : Color.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .offset(y: 90) // 버튼 높이만큼 내려서 팝업처럼 표시
                    }
                }
            )

            // 상태 메시지
            if let msg = state.messageText {
                Text(msg)
                    .font(.pretendardLight(12))
                    .foregroundColor(state.messageColor)
            }
        }
    }

    private func toggleDropdown() {
        withAnimation(.easeInOut) { isExpanded.toggle() }
    }

    private func select(_ option: String) {
        selection = option
        state = .normal
        withAnimation(.easeInOut) { isExpanded = false }
    }
}
