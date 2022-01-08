//
//  DataController-ApplePay.swift
//  Portfolio
//
//  Created by MacBook Pro on 02/01/2022.
//

import StoreKit

extension DataController {
    /// Looks for an active (currently used for input) scene
    func appLaunched() {
        guard count(for: Project.fetchRequest()) >= 5 else { return }
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
