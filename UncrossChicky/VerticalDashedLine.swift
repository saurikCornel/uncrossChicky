//
//  VerticalDashedLine.swift
//  MissionUncrossableChicken
//
//  Created by Alexander Belov on 2/2/25.
//

import Foundation
import SwiftUI

struct VerticalDashedLine: View {
    var body: some View {
        Canvas { context, size in
            let dashHeight: CGFloat = 25
            let spaceHeight: CGFloat = 20
            var y: CGFloat = 0
            
            while y < size.height {
                context.fill(
                    Path(CGRect(x: 0, y: y, width: 2, height: dashHeight)),
                    with: .color(.white)
                )
                y += dashHeight + spaceHeight
            }
        }
        .frame(width: 2) // Фиксируем ширину 5 пикселей
        .background(Color.clear)
    }
}
