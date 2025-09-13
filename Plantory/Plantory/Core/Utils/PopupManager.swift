//
//  PopupManager.swift
//  Plantory
//
//  Created by 주민영 on 9/13/25.
//

import SwiftUI

final class PopupManager: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var popupContent: AnyView = AnyView(EmptyView())
    
    func show<Content: View>(@ViewBuilder content: () -> Content) {
        popupContent = AnyView(content())
        withAnimation(.linear(duration: 0.15)) { isPresented = true }
    }
    
    func dismiss() {
        withAnimation(.linear(duration: 0.15)) { isPresented = false }
        popupContent = AnyView(EmptyView())
    }
}
