//
//  PurchaseButton.swift
//  Portfolio
//
//  Created by MacBook Pro on 02/01/2022.
//

import SwiftUI

/// Custom button style so that button stands out more
struct PurchaseButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 200, minHeight: 44)
            .background(Color("Light Blue"))
            .clipShape(Capsule())
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
