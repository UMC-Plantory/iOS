//
//  PlantPopupModel.swift
//  Plantory
//
//  Created by 박정환 on 7/22/25.
//

import Foundation
import Combine

class PlantPopupModel: ObservableObject {
    @Published var isPresented: Bool
    @Published var plantName: String
    @Published var feeling: String
    @Published var birthDate: String
    @Published var completeDate: String
    @Published var usedDates: [String]
    @Published var stages: [(String, String)]

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
