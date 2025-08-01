//
//  PermitModel.swift
//  Plantory
//
//  Created by 주민영 on 7/9/25.
//

import SwiftUI

struct PermitItem: Identifiable {
    let id = UUID()
    let title: String
    let showDetail: Bool
    let binding: Binding<Bool>
}
