//
//  PortfolioApp.swift
//  Portfolio
//
//  Created by MacBook Pro on 10/11/2021.
//

import SwiftUI

@main
struct PortfolioApp: App {
    @StateObject var dataController: DataController
    @StateObject var unlockManager: UnlockManager

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(unlockManager)
            // Automatically save when we detect that we are
            // no longer the foreground app. Use this rather than
            // scene phase so we can port to macOS, where scene
            // phase won't detect our app losing focus.
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.willResignActiveNotification),
                    perform: save)
        }
    }

    init() {
        // StateObjects are created using initialier because using
        // @StateObject var ... because those two properties depen one on another

        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)

        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)

    }

    func save(_ note: Notification) {
        dataController.save()
    }
}
