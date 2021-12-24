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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.willResignActiveNotification),
                    perform: save)
        }
    }

    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }

    func save(_ note: Notification) {
        dataController.save()
    }
}
