//
//  PermitModel.swift
//  Plantory
//
//  Created by 주민영 on 7/9/25.
//

import SwiftUI

struct PermitItem: Identifiable {
    let id = UUID()
    let num: Int
    let title: String
    let binding: Binding<Bool>
}

struct TermsSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}
