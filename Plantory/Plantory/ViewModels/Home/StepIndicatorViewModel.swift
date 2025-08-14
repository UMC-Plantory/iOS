//
//  StepIndicatorViewModel.swift
//  Plantory
//
//  Created by 김지우 on 7/24/25.
//


//
//  StepIndicatorViewModel.swift
//  Plantory
//
//  Created by 김지우 on 7/15/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
class StepIndicatorViewModel {
    var currentStep: Int = 0
    var isCompleted: Bool = false

    let steps: [Step] = [
        Step(title: "감정"),
        Step(title: "일기"),
        Step(title: "사진"),
        Step(title: "취침")
    ]

    func goNext() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        }
    }

    func goBack() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    func complete() {
        isCompleted = true
    }
}
