//
//  PlantPopupModel.swift
//  Plantory
//
//  Created by 박정환 on 7/22/25.
//

import Foundation

struct PlantPopupModel {
    var isPresented: Bool
    var plantName: String
    var feeling: String
    var birthDate: String
    var completeDate: String
    var usedDates: [String]
    var stages: [(String, String)]

    init(isPresented: Bool, plantName: String, feeling: String, birthDate: String, completeDate: String, usedDates: [String], stages: [(String, String)]) {
        self.isPresented = isPresented
        self.plantName = plantName
        self.feeling = feeling
        self.birthDate = birthDate
        self.completeDate = completeDate
        self.usedDates = usedDates
        self.stages = stages
    }
}
