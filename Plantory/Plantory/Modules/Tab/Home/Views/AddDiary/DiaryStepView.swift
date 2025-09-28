//
//  DiaryStepView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

struct DiaryStepView: View {
    @Bindable var vm: AddDiaryViewModel
    let maxLength: Int = 300
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Spacer().frame(height: 40)

        VStack {
            Text("오늘은 어떤 일이 있었나요?")
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.adddiaryfont)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Spacer()
                Text("\(vm.content.count)/\(maxLength)")
                    .foregroundColor(vm.content.count > maxLength ? .red : .gray06)
                    .font(.caption)
                Spacer().frame(width: 5)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(colorScheme == .dark ? Color.clear : Color.green04, lineWidth: 1)

                TextEditor(text: $vm.content)
                    .padding(8)
                    .font(.pretendardRegular(16))
                    .foregroundStyle(.black)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .onChange(of: vm.content) { newValue in
                        if newValue.count > maxLength {
                            vm.content = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .frame(width: 355, height: 376)
        }
    }
}
