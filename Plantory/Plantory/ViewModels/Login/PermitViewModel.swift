//
//  PermitViewModel.swift
//  Plantory
//
//  Created by 주민영 on 7/8/25.
//

import SwiftUI
import Observation

@Observable
class PermitViewModel {
    var allPermit: Bool {
        get {
            termsOfServicePermit &&
            informationPermit &&
            marketingPermit        }
        set {
            withAnimation {
                termsOfServicePermit = newValue
                informationPermit = newValue
                marketingPermit = newValue
            }
        }
    }
    
    var termsOfServicePermit: Bool = false
    var informationPermit: Bool = false
    var marketingPermit: Bool = false
}
