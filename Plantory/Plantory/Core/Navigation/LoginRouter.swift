//
//  LoginRouter.swift
//  Plantory
//
//  Created by 주민영 on 11/11/25.
//

import SwiftUI

final class LoginRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ destination: LoginDestination) {
        path.append(destination)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func reset() {
        path = NavigationPath()
    }
}
