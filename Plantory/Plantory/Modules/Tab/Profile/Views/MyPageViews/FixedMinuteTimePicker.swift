import SwiftUI

// MARK: - AM/PM 전용 타입
enum Meridiem: String, CaseIterable, Hashable, CustomStringConvertible {
    case am, pm
    var description: String { rawValue.uppercased() } // "AM", "PM"
}

extension Int: CustomStringConvertible {
    public var description: String { "\(self)" }
}

struct FixedMinuteTimePicker_Custom: View {
    @Binding var hour: Int      // 1...12
    @Binding var isPM: Bool     // false=AM, true=PM

    private let hours = Array(1...12)

    var rowHeight: CGFloat = 44
    var columnSpacing: CGFloat = 30
    var lineColor: Color = .green

    var body: some View {

        let meridiemBinding = Binding<Meridiem>(
            get: { isPM ? .pm : .am },
            set: { isPM = ($0 == .pm) }
        )

        HStack(spacing: 20) {

            // 시 Picker (1~12)
            Picker("", selection: $hour) {
                ForEach(hours, id: \.self) { h in
                    Text("\(h)")
                        .font(.pretendardRegular(18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 45)
            .clipped()
            .labelsHidden()

            Text(":")
                .font(.pretendardRegular(18))

            Text("00")
                .font(.pretendardRegular(18))
                .frame(width: 30)
                .frame(maxHeight: .infinity)

            // AM / PM
            Picker("", selection: meridiemBinding) {
                ForEach(Meridiem.allCases, id: \.self) { m in
                    Text(m.description)
                        .font(.pretendardRegular(18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 50)
            .clipped()
            .labelsHidden()
        }
        .padding(.vertical, 18)
        .frame(height: rowHeight * 3.5)
    }
}


