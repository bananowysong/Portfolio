//
//  Binding-OnChange.swift
//  Portfolio
//
//  Created by MacBook Pro on 14/11/2021.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(get: { self.wrappedValue },
                set: { newValue in
            self.wrappedValue = newValue
            handler()
        })
    }
}
