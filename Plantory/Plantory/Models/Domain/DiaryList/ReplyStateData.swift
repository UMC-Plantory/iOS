//
//  ReplyState.swift
//  Plantory
//
//  Created by 주민영 on 9/30/25.
//

import SwiftData

@Model
class ReplyStateData {
    @Attribute(.unique) var id: Int
    var isOpened: Bool
    
    init(id: Int, isOpened: Bool = false) {
        self.id = id
        self.isOpened = isOpened
    }
}
