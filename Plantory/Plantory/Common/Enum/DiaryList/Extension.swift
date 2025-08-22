//
//  Extension.swift
//  Plantory
//
//  Created by 박병선 on 8/22/25.
//


import Foundation

extension String {
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = .current
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}

extension Date {
    func toKoreanDiaryFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd (E)"  // (E) = 요일
        return formatter.string(from: self)
    }
}
