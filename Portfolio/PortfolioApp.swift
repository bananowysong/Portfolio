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
        }
    }

    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
}
