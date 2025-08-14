//
//  TerrariumTab.swift
//  Plantory
//
//  Created by 박정환 on 7/16/25.
//

enum TerrariumTab: String, CaseIterable, Identifiable {
    case terrarium = "테라리움"
    case myGarden = "나의 정원"

    var id: String { self.rawValue }
}
