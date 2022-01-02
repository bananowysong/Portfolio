//
//  SceneDelegate.swift
//  Portfolio
//
//  Created by MacBook Pro on 02/01/2022.
//

import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    // Asks SwiftUI to open the URL using the current scene
    @Environment(\.openURL) var openURL

    // works only when scene already exists!
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void) {
            // Converts shortcut type into URL
            guard let url = URL(string: shortcutItem.type) else {
                completionHandler(false)
                return
            }

            openURL(url, completion: completionHandler)
    }

    // Called when the scene is being created (cold launch), but might be called before
    // SwiftUI finishes creating views (willType of callback)
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // shortcut item that triggered the scene connection
        if let shortcutItem = connectionOptions.shortcutItem {
            guard let url = URL(string: shortcutItem.type) else {
                return
            }

            openURL(url)
        }
    }
}
