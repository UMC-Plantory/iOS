//
//  NavigationBackSwipe.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import Foundation
import UIKit

// UINavigationController를 확장하여 ObservableObject 및 UIGestureRecognizerDelegate 프로토콜을 채택
extension UINavigationController: @retroactive ObservableObject, @retroactive UIGestureRecognizerDelegate {
    
    /// 뷰가 로드될 때 호출되는 메서드
    override open func viewDidLoad() {
        super.viewDidLoad()
        // 스와이프 제스처(인터랙티브 팝 제스처)의 delegate를 현재 UINavigationController로 설정
        interactivePopGestureRecognizer?.delegate = self
    }
    
    /// 스와이프 제스처(뒤로 가기)가 시작되기 전에 실행되는 delegate 메서드
    /// - Returns: 이전 화면이 존재할 경우(true)만 스와이프 제스처를 허용
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
