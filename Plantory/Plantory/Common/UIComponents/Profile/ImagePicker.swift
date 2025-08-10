//
//  ImagePicker.swift
//  Plantory
//
//  Created by 이효주 on 7/22/25.
//


import UIKit
import SwiftUI

// MARK: - ImagePicker
/// UIKit UIImagePickerController를 래핑하여 SwiftUI에서 사용
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary  // 사진 라이브러리에서 선택
        return picker
    }

    // 업데이트 시 별도 처리가 필요 없으므로 빈 구현
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // MARK: - Coordinator
    /// UIImagePickerControllerDelegate 구현
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        // 이미지 선택 후 호출
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage  // 선택된 이미지 바인딩 업데이트
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        // 취소 시 호출: 모달 닫기
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
