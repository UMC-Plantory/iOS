//
//  SessionManager.swift
//  Plantory
//
//  Created by 주민영 on 9/30/25.
//

import SwiftUI
import Combine

final class SessionManager: ObservableObject {
    @AppStorage("isLoggedIn") private var storedIsLoggedIn: Bool = false
    @Published var isLoggedIn: Bool = false

    init() {
        self.isLoggedIn = storedIsLoggedIn
    }

    func login() {
        isLoggedIn = true
        storedIsLoggedIn = true
    }

    func logout() {
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.storedIsLoggedIn = false
        }
    }
}
