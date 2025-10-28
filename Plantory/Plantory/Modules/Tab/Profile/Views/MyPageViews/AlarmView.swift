import SwiftUI

struct AlarmView: View {
    @State private var hour = 6
    @State private var isPM = true
    @Environment(\.dismiss) private var dismiss   // 시트 닫기용

    var body: some View {
        VStack {
            // MARK: - Header View
            HStack {
                Button {
                    dismiss()                      // 취소 → 시트 닫기
                } label: {
                    Text("취소")
                        .font(.pretendardRegular(18))
                        .foregroundStyle(.green06)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("알람 설정")
                    .font(.pretendardBold(18))
                    .foregroundStyle(.black01Dynamic)

                Spacer()

                Button {
                    print("저장")                  // 저장 → print
                } label: {
                    Text("저장")
                        .font(.pretendardRegular(18))
                        .foregroundStyle(.green06)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.top, 30)
            .padding(.bottom, 26)

            Divider()

            FixedMinuteTimePicker_Custom(
                hour: $hour,
                isPM: $isPM,
                rowHeight: 43,
                columnSpacing: 30,
                lineColor: .green04
            )
        }
    }
}

#Preview {
    AlarmView()
}
