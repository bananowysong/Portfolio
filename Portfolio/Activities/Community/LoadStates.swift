//
//  LoadStates.swift
//  Portfolio
//
//  Created by MacBook Pro on 08/01/2022.
//

import Foundation

/// Enum describing load state.
enum LoadState {
    /// No data request has been made yet
    case inactive
    /// A data request is currently in flight
    case loading
    /// Some successful data has been received
    case success
    /// The request finished without any results
    case noResults
}
