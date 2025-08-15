//
//  SleepStepView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

struct SleepStepView: View {
    @State private var wakeHour: Int = 9
    @State private var wakeMinute: Int = 0
    @State private var wakePeriod: String = "AM"

    @State private var sleepHour: Int = 11
    @State private var sleepMinute: Int = 59
    @State private var sleepPeriod: String = "PM"

    private let hours = Array(1...12)
    private let minutes = Array(0...59)
    private let periods = ["AM", "PM"]

    var body: some View {
        VStack(spacing: 40) {
            Text("하루의 시작과 마무리를 기록해보세요!")
                .font(.pretendardSemiBold(20))
                .foregroundColor(.diaryfont)

            // MARK: - 기상
            VStack(spacing: 12) {
                Text("기상")
                    .font(.pretendardSemiBold(20))
                    .foregroundStyle(.diaryfont)

                ZStack {
                    HStack(spacing: 0) {
                        Picker("", selection: $wakeHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour)")
                                    .foregroundStyle(hour == wakeHour ? .green04 : .diaryfont)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)

                        Text(":")
                            .foregroundStyle(.diaryfont)
                        Spacer().frame(width: 4)

                        Picker("", selection: $wakeMinute) {
                            ForEach(minutes, id: \.self) { minute in
                                    Text(String(format: "%02d", minute))
                                        .foregroundStyle(minute == wakeMinute ? .green04 : .diaryfont)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)

                        Picker("", selection: $wakePeriod) {
                            ForEach(periods, id: \.self) { period in
                                Text(period)
                                    .foregroundStyle(period == wakePeriod ? .green04 : .diaryfont)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                    }
                    .font(.pretendardSemiBold(18))
                }
            }

            // MARK: - 취침
            VStack(spacing: 16) {
                Text("취침")
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(.diaryfont)

                ZStack {
                    HStack(spacing: 0) {
                        Picker("", selection: $sleepHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour)")
                                    .foregroundStyle(hour == sleepHour ? .green04 : .diaryfont)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)

                        Text(":")
                            .foregroundStyle(.diaryfont)
                        Spacer().frame(width: 4)

                        Picker("", selection: $sleepMinute) {
                            ForEach(minutes, id: \.self) { minute in
                                Text(String(format: "%02d", minute))
                                    .foregroundStyle(minute == sleepMinute ? .green04 : .diaryfont)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)

                        Picker("", selection: $sleepPeriod) {
                            ForEach(periods, id: \.self) { period in
                                Text(period)
                                    .foregroundStyle(period == sleepPeriod ? .green04 : .diaryfont)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                    }
                    .font(.pretendardSemiBold(18))
                }
            }
            Spacer()
        }
        .padding()
    }
}

