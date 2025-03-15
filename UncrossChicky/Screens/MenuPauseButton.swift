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
                .fill(Color(hex: "#00CBEC"))
            
            Text(text)
               
        }
        
        .frame(width: 150, height: 40)
        .onTapGesture {
            action()
        }
        
           
        
    }
}


#Preview {
    MenuPauseButton(text: "Check", action: {
        
    })
}
