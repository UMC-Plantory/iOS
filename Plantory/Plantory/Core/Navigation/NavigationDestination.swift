//
//  NavigationDestination.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import Foundation

enum NavigationDestination: Equatable, Hashable {
    case login
    case permit
    case policy(num: Int)
    case baseTab
}
