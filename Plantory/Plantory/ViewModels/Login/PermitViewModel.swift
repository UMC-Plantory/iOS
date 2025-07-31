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
            fourteenPermit &&
            termsOfServicePermit &&
            informationPermit &&
            locationPermit &&
            marketingPermit        }
        set {
            withAnimation {
                fourteenPermit = newValue
                termsOfServicePermit = newValue
                informationPermit = newValue
                locationPermit = newValue
                marketingPermit = newValue
            }
        }
    }
    
    var fourteenPermit: Bool = false
    var termsOfServicePermit: Bool = false
    var informationPermit: Bool = false
    var locationPermit: Bool = false
    var marketingPermit: Bool = false
}
