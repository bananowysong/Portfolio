//
//  Error-CloudKitMessage.swift
//  Portfolio
//
//  Created by MacBook Pro on 09/01/2022.
//

import CloudKit
import Foundation

extension Error {

    /// Turns error objects (specifically Cloud Kit Errors) into Strings
    /// - Returns: String
    func getCloudKitError() -> CloudError {

        // Checks if CloudKit error occurred
        guard let error = self as? CKError else {
            return "An unknown error occured: \(self.localizedDescription)"
        }

        switch error.code {
        case .badContainer, .badDatabase, .invalidArguments:
            return "A fatal error occurred: \(error.localizedDescription)"
        case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
            return "There was a problem communicating with iCloud, please check your network connection and try again."
        case .notAuthenticated:
            return "There was a problem with your iCloud account, please check that you're logged in to iCloud."
        case .requestRateLimited:
            return "You've hit iClouds's rate limit; please wait a moment and try again."
        case .quotaExceeded:
            return "You've exceeded your iCloud quota; please clear up some space then try again."
        default:
            return "An unknown error occurred \(error.localizedDescription)"
        }

    }
}
