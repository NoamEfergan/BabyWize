//
//  SplashScreen.swift
//  BabyWize
//
//  Created by Noam Efergan on 06/11/2022.
//

import SwiftUI

struct SplashScreen: View {
    let gradient: LinearGradient = .init(colors: [Color("gradientYellow"), Color("gradientPink")], startPoint: .bottom, endPoint: .top)
    
    var body: some View {
        ZStack {
            gradient
                .ignoresSafeArea()
            Image("NoBGLogo")
                .resizable()
                .aspectRatio(1*1, contentMode: .fit)
                .frame(width: 185)
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
