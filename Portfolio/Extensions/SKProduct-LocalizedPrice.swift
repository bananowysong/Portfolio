//
//  SKProduct-LocalizedPrice.swift
//  Portfolio
//
//  Created by MacBook Pro on 02/01/2022.
//

import StoreKit

extension SKProduct {
    /// Used to make textual representation of the price
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
