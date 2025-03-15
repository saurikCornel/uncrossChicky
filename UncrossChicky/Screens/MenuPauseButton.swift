//
//  MenuPauseButton.swift
//  UncrossChicky
//
//  Created by alex on 3/15/25.
//

import Foundation
import SwiftUI

struct MenuPauseButton: View {
    
    var text: String
    
    var action: () -> Void
    
    var body: some View {
        
        
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color(hex: "#22224D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.white, lineWidth: 3)
                            )
            
            Text(text)
                .foregroundColor(.white)
               
        }
        
        .frame(width: 150, height: 40)
        .onTapGesture {
            Navigator.shared.selectedScreen = .MENU
        }
        
           
        
    }
}


#Preview {
    MenuPauseButton(text: "Check", action: {
        
    })
}
