//
//  InteractivePopDisabled.swift
//  Plantory
//
//  Created by Assistant on 1/5/26.
//

import SwiftUI
import UIKit

private struct InteractivePopDisabled: ViewModifier {
    let disabled: Bool

    func body(content: Content) -> some View {
        content
            .background(ControllerToggler(disabled: disabled))
    }

    // 브릿지: 현재 화면이 보이는 동안 네비게이션 컨트롤러의 interactivePop 제스처 on/off
    private struct ControllerToggler: UIViewControllerRepresentable {
        let disabled: Bool

        func makeUIViewController(context: Context) -> UIViewController {
            TogglerViewController(disabled: disabled)
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            if let vc = uiViewController as? TogglerViewController {
                vc.disabled = disabled
                vc.updateGestureState()
            }
        }

        final class TogglerViewController: UIViewController {
            var disabled: Bool

            init(disabled: Bool) {
                self.disabled = disabled
                super.init(nibName: nil, bundle: nil)
            }

            required init?(coder: NSCoder) {
                self.disabled = false
                super.init(coder: coder)
            }

            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                updateGestureState()
            }

            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                // 화면이 내려갈 때는 복구
                setInteractivePopEnabled(true)
            }

            func updateGestureState() {
                setInteractivePopEnabled(!disabled ? true : false)
            }

            private func setInteractivePopEnabled(_ enabled: Bool) {
                // 가장 가까운 UINavigationController 찾아서 제스처 토글
                if let nav = findNavigationController(from: self) {
                    nav.interactivePopGestureRecognizer?.isEnabled = enabled
                    // 제스처가 꺼졌을 때 충돌 방지를 위해 delegate 유지
                }
            }

            private func findNavigationController(from vc: UIViewController?) -> UINavigationController? {
                var current = vc
                while let c = current {
                    if let nav = c.navigationController {
                        return nav
                    }
                    current = c.parent
                }
                return nil
            }
        }
    }
}

extension View {
    /// 이 뷰가 표시되는 동안 네비게이션의 스와이프-뒤로 제스처를 비활성화
    func interactivePopDisabled(_ disabled: Bool) -> some View {
        modifier(InteractivePopDisabled(disabled: disabled))
    }
}
