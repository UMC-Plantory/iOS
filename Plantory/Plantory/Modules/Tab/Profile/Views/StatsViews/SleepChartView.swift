//
//  SleepChartView.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI
import Charts

// MARK: - WeekChartView
struct WeekChartView: View {
    let daily: [DailySleep]
    
    // y축 도메인(21시부터 +24h) 및 눈금 설정
    private let axisMin: Double = 21
    private var domainLower: Double { axisMin }
    private var domainUpper: Double { axisMin + 24 }
    private var yTickValues: [Double] { [21, 25, 29, 33, 37, 41, 45] }
    private var yTickLabels: [String] {
        ["21:00", "01:00", "05:00", "09:00", "13:00", "17:00", "21:00"]
    }
    
    var body: some View {
        Chart {
            ForEach(daily) { record in
                BarMark(
                    x: .value("요일", record.weekday),
                    yStart: .value("취침", flipped(numericHour(from: record.startTime))),
                    yEnd:   .value("기상", flipped(numericHour(from: record.endTime))),
                    width:  .fixed(21)
                )
                .cornerRadius(50)
                .shadow(color: .black.opacity(0.1), radius: 2, x:2, y:1)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.green01, location: 0.0),
                            .init(color: Color.green02, location: 0.5),
                            .init(color: Color.green03, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        // y축 커스텀 눈금
        .chartYScale(domain: domainLower...domainUpper)
        .chartYAxis {
            AxisMarks(position: .leading, values: yTickValues) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5,5]))
                    .foregroundStyle(Color.gray07)
                if let v = value.as(Double.self),
                   let idx = Array(yTickValues.reversed()).firstIndex(of: v) {
                    AxisValueLabel(yTickLabels[idx])
                        .font(.pretendardRegular(12))
                        .foregroundStyle(.gray09)
                }
            }
        }
        // x축: 요일 아래에 날짜(“6/15”) 포함
        .chartXAxis {
            AxisMarks(values: daily.map(\.weekday)) { value in
                AxisValueLabel {
                    if let weekday = value.as(String.self),
                       let rec = daily.first(where: { $0.weekday == weekday }) {
                        VStack(spacing: 2) {
                            Text(weekday)
                            Text(rec.date, format: .dateTime
                                                        .month(.defaultDigits)
                                                        .day(.defaultDigits))
                        }
                        .font(.pretendardRegular(12))
                        .foregroundStyle(.gray09)
                    }
                }
            }
        }
        .frame(height: 366)
    }
    
    // Date → 연속값(시간) 변환: 21시 기준 넘어가면 +24h
    private func numericHour(from date: Date) -> Double {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        var h = Double(comps.hour ?? 0) + Double(comps.minute ?? 0) / 60
        if h < axisMin { h += 24 }
        return h
    }
    
    // y축 뒤집기를 위한 보정
    private func flipped(_ value: Double) -> Double {
        domainLower + domainUpper - value
    }
}

// MARK: - MonthChartView
struct MonthChartView: View {
    // 외부에서 호출가능한 기본 생성자
    init(weekly: [WeeklyInterval]) {
        self.weekly = weekly
    }

    let weekly: [WeeklyInterval]

    private let axisMin = 21.0
    private var domainLower: Double { axisMin }
    private var domainUpper: Double { axisMin + 24 }
    private var yTicks: [Double] { [21,25,29,33,37,41,45] }
    private var yLabels = ["21:00","01:00","05:00","09:00","13:00","17:00","21:00"]

    var body: some View {
        Chart {
            ForEach(weekly) { rec in
                BarMark(
                    x: .value("주차", rec.week),
                    yStart: .value("취침", flipped(numericHour(from: rec.startTime))),
                    yEnd:   .value("기상", flipped(numericHour(from: rec.endTime))),
                    width:  .fixed(20)
                )
                .cornerRadius(50)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 1)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.green01, location: 0),
                            .init(color: Color.green02, location: 0.5),
                            .init(color: Color.green03, location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartYScale(domain: domainLower...domainUpper)
        .chartYAxis {
            AxisMarks(position: .leading, values: yTicks) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5,5]))
                    .foregroundStyle(Color.gray09)
                if let v = value.as(Double.self),
                   let i = Array(yTicks.reversed()).firstIndex(of: v) {
                    AxisValueLabel(yLabels[i])
                        .font(.pretendardRegular(12))
                        .foregroundStyle(.gray09)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: weekly.map(\.week)) { value in
                AxisValueLabel {
                    if let w = value.as(String.self) {
                        Text("\(w)주차")
                            .font(.pretendardRegular(12))
                            .foregroundStyle(.gray09)
                    }
                }
            }
        }
        .frame(height: 366)
    }

    private func numericHour(from date: Date) -> Double {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        var h = Double(comps.hour ?? 0) + Double(comps.minute ?? 0)/60
        if h < axisMin { h += 24 }
        return h
    }

    private func flipped(_ v: Double) -> Double {
        domainLower + domainUpper - v
    }
}
