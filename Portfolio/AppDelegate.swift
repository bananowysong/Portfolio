//
//  AppDelegate.swift
//  Portfolio
//
//  Created by MacBook Pro on 02/01/2022.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

    // Lets the application know that when it comes time to create a new scene
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            let sceneConfiguration = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
            sceneConfiguration.delegateClass = SceneDelegate.self

            return sceneConfiguration
    }
}
