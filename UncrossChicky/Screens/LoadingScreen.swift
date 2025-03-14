//
//  LoadingScreen.swift
//  MissionUncrossableChicken
//
//  Created by Alexander Belov on 2/2/25.
//

import Foundation
import SwiftUI



struct LoadingScreen: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    Image(.chickyLogo)
                        .resizable()
                        .scaledToFit()
                        .padding(30)
                    Spacer()
                }
                Image("chckn1player")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width * 0.4)
                
               
            }
            .frame(width: geo.size.width, height: geo.size.height)
           
        }
        .background(
            
            Image("loadingScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                
        )
    }
}


#Preview {
    LoadingScreen()
}
