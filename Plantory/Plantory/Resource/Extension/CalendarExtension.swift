//
//  CalendarExtension.swift
//  Plantory
//
//  Created by 주민영 on 8/22/25.
//

import SwiftUI

extension Calendar {
    func year(_ date: Date = .now) -> Int { component(.year, from: date) }
}
