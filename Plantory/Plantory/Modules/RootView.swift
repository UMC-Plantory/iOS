//
//  RootView.swift
//  Plantory
//
//  Created by 주민영 on 9/30/25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("lastResetDate") private var lastResetDate: Date?
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        Group {
            if sessionManager.isLoggedIn {
                NavigationRoutingView()
                   .environmentObject(container)
                   .environmentObject(sessionManager)
            } else {
                LoginView(container: container, sessionManager: sessionManager)
            }
        }
        .animation(.easeInOut, value: sessionManager.isLoggedIn)
        .onAppear {
            resetIfNeeded()
        }
    }
    
    private func resetIfNeeded() {
        let now = Date()
        
        if let last = lastResetDate {
            if let days = Calendar.current.dateComponents([.day], from: last, to: now).day,
               days >= 30 {
                resetDatabase()
                lastResetDate = now
            }
        } else {
            // 최초 실행 → 초기화 날짜 기록만
            lastResetDate = now
        }
    }
    
    private func resetDatabase() {
        do {
            try context.delete(model: ReplyStateData.self)
            try context.save()
            print("SwiftData 초기화 완료")
        } catch {
            print("초기화 실패: \(error)")
        }
    }
}
