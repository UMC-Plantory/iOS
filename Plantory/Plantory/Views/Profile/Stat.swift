//
//  Stat.swift
//  Plantory
//
//  Created by 이효주 on 7/8/25.
//

import Foundation

struct Stat: Identifiable, Hashable {
    let id = UUID()
    let value: String
    let label: String
}
