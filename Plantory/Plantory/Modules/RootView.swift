//
//  RootView.swift
//  Plantory
//
//  Created by 주민영 on 9/30/25.
//
import SwiftUI

struct RootView: View {
    @AppStorage("lastResetDate") private var lastResetDate: Date?
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var sessionManager: SessionManager
    
    // splash 상태 관리
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                Group {
                    if sessionManager.isLoggedIn {
                        NavigationRoutingView()
                            .environmentObject(container)
                            .environmentObject(sessionManager)
                    } else {
                        LoginNavigationView()
                            .environmentObject(container)
                            .environmentObject(sessionManager)
                    }
                }
                .animation(.easeInOut, value: sessionManager.isLoggedIn)
            }
        }
        .onAppear {
            resetIfNeeded()
            showSplashTemporarily()
        }
    }

    // MARK: - 스플래시 제어
    private func showSplashTemporarily() {
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeOut) {
                showSplash = false
            }
        }
    }
    
    // MARK: - 리셋
    private func resetIfNeeded() {
        let now = Date()
        if let last = lastResetDate {
            if let days = Calendar.current.dateComponents([.day], from: last, to: now).day,
               days >= 30 {
                resetDatabase()
                lastResetDate = now
            }
        } else {
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
