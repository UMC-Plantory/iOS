//
//  SessionManager.swift
//  Plantory
//
//  Created by 주민영 on 9/30/25.
//

import SwiftUI
import Combine

class SessionManager: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    func logout() {
        DispatchQueue.main.async {
            self.isLoggedIn = false
        }
    }
}
