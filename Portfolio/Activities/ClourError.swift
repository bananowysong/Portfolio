//
//  ClourError.swift
//  Portfolio
//
//  Created by MacBook Pro on 09/01/2022.
//

import Foundation

/// Wraps error strings in a type so that they are identifiable and can be used in alerts etc
struct CloudError: Identifiable, ExpressibleByStringInterpolation {
    var id: String { message }
    var message: String

    init(stringLiteral value: String) {
        self.message = value
    }

}
