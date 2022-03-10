//
//  LocketModeControl.swift
//  GrandaLocket
//
//  Created by Сердюков Евгений on 10.02.2022.
//

import UIKit
import SwiftUI
import AudioToolbox

struct LocketModeControl: View {
    @Binding var selectedMode: LocketMode

    func calculateOffset() -> CGFloat {
        return selectedMode == .photo ? 30 : -40
    }

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Button {
                    withAnimation {
                        selectedMode = .photo
                    }
                } label: {
                    Text(LocketMode.photo.rawValue)
                        .bold()
                        .foregroundColor(selectedMode == .photo ? .white: .white.opacity(0.7))
                }
                Button {
                    withAnimation {
                        selectedMode = .text
                    }
                } label: {
                    Text(LocketMode.text.rawValue)
                        .bold()
                        .foregroundColor(selectedMode == .text ? .white: .white.opacity(0.7))
                }
            }
            .offset(x: calculateOffset())
            .animation(.default, value: calculateOffset())
            Image("angle_up_color")
                .renderingMode(.template)
                .foregroundColor(.init(Palette.accent))
                .animation(.default, value: selectedMode)
        }

    }
}
