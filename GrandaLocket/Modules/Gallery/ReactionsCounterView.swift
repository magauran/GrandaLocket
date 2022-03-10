//
//  ReactionsCounterView.swift
//  GrandaLocket
//
//  Created by Alexey Salangin on 09.03.2022.
//

import SwiftUI

struct ReactionsCounterView: View {
    let count: Int

    var body: some View {
        Text("\(count)🔥")
            .foregroundColor(.white)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .padding(.init(top: 6, leading: 6, bottom: 6, trailing: 6))
            .background(.black.opacity(0.5))
            .clipShape(Capsule())
            .opacity(count > 0 ? 1 : 0)
    }
}
