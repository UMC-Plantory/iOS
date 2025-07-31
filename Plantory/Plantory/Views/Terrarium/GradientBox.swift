//
//  GradientBox.swift
//  Plantory
//
//  Created by 박정환 on 7/21/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

struct GradientBox: View {
    var width: CGFloat = 44
    var height: CGFloat = 21
    var cornerRadius: CGFloat = 5
    var LightGradient: Bool = false
    var isCircle: Bool = false

    var body: some View {
        let linearGradient = LinearGradient(
            gradient: Gradient(colors: LightGradient
                               ? [Color(hex: "#87C409"), Color(hex: "#E1F9B1")]
                               : [Color(hex: "#41882E"), Color(hex: "#E1F9B1")]),
            startPoint: .top,
            endPoint: .bottom
        )

        let radialGradient = RadialGradient(
            gradient: Gradient(colors: [Color(hex: "#FFF944"), Color( "green03")]),
            center: .center,
            startRadius: 1,
            endRadius: width / 2
        )

        return Group {
            if isCircle {
                Circle()
                    .fill(radialGradient)
                    .frame(width: width, height: width)
            } else {
                Rectangle()
                    .fill(linearGradient)
                    .frame(width: width, height: height)
                    .cornerRadius(cornerRadius)
            }
        }
    }
}

struct GradientBox_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            GradientBox(LightGradient: true)
            GradientBox(LightGradient: false)
            GradientBox(width: 51, isCircle: true)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
