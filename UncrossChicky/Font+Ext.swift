//
//  Font+Ext.swift
//  MissionUncrossableChicken
//
//  Created by Alexander Belov on 2/2/25.
//

import Foundation
import SwiftUI

extension View {
    func cFont(size: CGFloat, color: Color, weight: Font.Weight = .regular, italic: Bool = false, bold: Bool = false) -> some View {
        var font = Font.custom("Venus Rising", size: size)
        
        if bold {
            font = font.weight(.bold)
        } else {
            font = font.weight(weight)
        }
        
        if italic {
            font = font.italic()
        }
        
        return self.font(font).foregroundColor(color)
    }
}
