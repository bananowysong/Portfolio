//
//  ContentView.swift
//  Portfolio
//
//  Created by MacBook Pro on 10/11/2021.
//

import SwiftUI
import CoreSpotlight

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: String?
    @EnvironmentObject var dataController: DataController

    var body: some View {
        TabView(selection: $selectedView) {
            HomeView(dataController: dataController)
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            ProjectsView(dataController: dataController, showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }

            ProjectsView(dataController: dataController, showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }

            AwardsView()
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Awards")
                }

            SharedProjectsView()
                .tag(SharedProjectsView.tag)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Community")
                }
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome(_:))
        .onOpenURL(perform: openURL(_:))
    }

    /// Moves the HomveView on top of stack when the app is launched by selecting spotlight item
    /// - Parameter input: NSSearchActivity
    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
    }

    /// Moves the ProjectsView on top of navigation stack when app is launched using shortcut and creates new project
    /// - Parameter url: URL
    func openURL(_ url: URL) {
        selectedView = ProjectsView.openTag
        // Project is created here because SwiftUI had some problems with calling
        // OpenURL on different TAB than the one that is opened on default
        // When COLD STARTING
        _ = dataController.addProject()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
