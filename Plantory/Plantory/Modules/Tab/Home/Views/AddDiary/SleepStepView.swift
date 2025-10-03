//
//  SleepStepView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

private enum SleepFormatters {
    static let day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
    static let isoMinute: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
}

struct SleepStepView: View {
    @Bindable var vm: AddDiaryViewModel
    let selectedDate: Date

    // 기본값
    @State private var wakeHour: Int = 7
    @State private var wakeMinute: Int = 0
    @State private var wakePeriod: String = "AM"

    @State private var sleepHour: Int = 11
    @State private var sleepMinute: Int = 0
    @State private var sleepPeriod: String = "PM"

    private let hours = Array(1...12)
    private let minutes = Array(0...59)
    private let periods = ["AM", "PM"]

    var body: some View {
        VStack(spacing: 40) {
            Text("하루의 시작과 마무리를 기록해보세요!")
                .font(.pretendardSemiBold(20))
                .foregroundColor(.adddiaryfont)

            //취침 시간 선택
            VStack(spacing: 16) {
                Text("취침")
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(.adddiaryfont)

                timePickers(hour: $sleepHour, minute: $sleepMinute, period: $sleepPeriod)
            }

            //기상 시간 선택
            VStack(spacing: 12) {
                Text("기상")
                    .font(.pretendardSemiBold(20))
                    .foregroundStyle(.adddiaryfont)

                timePickers(hour: $wakeHour, minute: $wakeMinute, period: $wakePeriod)
            }

            Spacer()
        }
        .padding()
        .onAppear { recalcAndSave() }
        .onChange(of: wakeHour) { _ , _ in recalcAndSave() }
        .onChange(of: wakeMinute) { _ , _ in recalcAndSave() }
        .onChange(of: wakePeriod) { _ , _ in recalcAndSave() }
        .onChange(of: sleepHour) { _ , _ in recalcAndSave() }
        .onChange(of: sleepMinute) { _ , _ in recalcAndSave() }
        .onChange(of: sleepPeriod) { _ , _ in recalcAndSave() }
    }

    private func timePickers(hour: Binding<Int>, minute: Binding<Int>, period: Binding<String>) -> some View {
        ZStack {
            HStack(spacing: 0) {
                Picker("", selection: hour) {
                    ForEach(hours, id: \.self) { h in
                        Text("\(h)")
                            .foregroundStyle(h == hour.wrappedValue ? .green04 : .adddiaryfont)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)

                Text(":")
                    .foregroundStyle(.adddiaryfont)
                Spacer().frame(width: 4)

                Picker("", selection: minute) {
                    ForEach(minutes, id: \.self) { m in
                        Text(String(format: "%02d", m))
                            .foregroundStyle(m == minute.wrappedValue ? .green04 : .adddiaryfont)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)

                Picker("", selection: period) {
                    ForEach(periods, id: \.self) { p in
                        Text(p)
                            .foregroundStyle(p == period.wrappedValue ? .green04 : .adddiaryfont)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)
            }
            .font(.pretendardSemiBold(18))
        }
    }

    private func recalcAndSave() {
        // 선택 날짜의 자정 기준
        let baseDayStr = SleepFormatters.day.string(from: selectedDate)
        guard let baseDay = SleepFormatters.day.date(from: baseDayStr) else { return }

        // 12→24시 변환
        func to24h(_ h12: Int, _ period: String) -> Int {
            var h = h12 % 12
            if period == "PM" { h += 12 }
            if period == "AM" && h12 == 12 { h = 0 } // 12AM = 00
            return h
        }

        let sleepH24 = to24h(sleepHour, sleepPeriod)
        let wakeH24  = to24h(wakeHour,  wakePeriod)

        // 취침: 선택일의 시각
        var start = Calendar.current.date(bySettingHour: sleepH24, minute: sleepMinute, second: 0, of: baseDay)!

        // 기상: 취침보다 빠르면 다음날로 보정
        var end = Calendar.current.date(bySettingHour: wakeH24, minute: wakeMinute, second: 0, of: baseDay)!
        if end <= start {
            end = Calendar.current.date(byAdding: .day, value: 1, to: end)!
        }

        let startStr = SleepFormatters.isoMinute.string(from: start)
        let endStr   = SleepFormatters.isoMinute.string(from: end)
        vm.setSleepTimes(start: startStr, end: endStr)
    }
}
