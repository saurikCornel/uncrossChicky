//
//  DimmedOverlayModifier.swift
//  UncrossChicky
//
//  Created by alex on 3/15/25.
//

import Foundation
import Foundation
import SwiftUI

struct DimmedOverlayModifier<OverlayView: View>: ViewModifier {
    var isActive: Bool
    var overlayView: OverlayView

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isActive) // Делает контент неактивным при isActive == true
            if isActive {
                Color.black.opacity(0.5) // Затемнение фона
                    .edgesIgnoringSafeArea(.all)
                overlayView // Ваш кастомный оверлей
            }
        }
    }
}

extension View {
    func dimmedOverlay<OverlayView: View>(isActive: Bool, overlayView: OverlayView) -> some View {
        self.modifier(DimmedOverlayModifier(isActive: isActive, overlayView: overlayView))
    }
}
