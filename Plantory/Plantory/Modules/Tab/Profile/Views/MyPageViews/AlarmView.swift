import SwiftUI

struct AlarmView: View {
    @EnvironmentObject var statsVM: MyPageStatsViewModel

    @State private var hour = 6
    @State private var isPM = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            HStack {
                Button("취소") { dismiss() }
                    .font(.pretendardRegular(18))
                    .foregroundStyle(.green06)

                Spacer()

                Text("알람 설정")
                    .font(.pretendardBold(18))
                    .foregroundStyle(.black01Dynamic)

                Spacer()

                Button("저장") {
                    statsVM.patchPushTime(hour: hour, isPM: isPM)
                    dismiss()
                }
                .font(.pretendardRegular(18))
                .foregroundStyle(.green06)
            }
            .padding(.horizontal, 32)
            .padding(.top, 30)
            .padding(.bottom, 26)

            Divider()

            FixedMinuteTimePicker_Custom(
                hour: $hour,
                isPM: $isPM,
                rowHeight: 43,
                columnSpacing: 30,   // ← 이거 무시되고 내가 내부에서 spacing 따로 잡아줌
                lineColor: .green04
            )
        }
    }
}
