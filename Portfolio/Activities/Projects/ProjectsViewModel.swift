//
//  ProjectsViewModel.swift
//  Portfolio
//
//  Created by MacBook Pro on 26/12/2021.
//

import Foundation
import CoreData

extension ProjectsView {
    final class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        var sortOrder = Item.SortOrder.optimized
        let showClosedProjects: Bool
        let dataController: DataController
        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()
        /// Toggle to show the store front
        @Published var showingUnlockView = false

        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
            item.project = project
            item.creationDate = Date()

            // added priority and completed properties because without them
            // the home view didn't show the new items
            item.priority = 2
            item.completed = false
            dataController.save()
        }

        func delete(_ offsets: IndexSet, from project: Project) {
            let allItems = project.projectItems(using: sortOrder)

            for offset in offsets {
                let item = allItems[offset]
                dataController.delete(item)
            }

            dataController.save()
        }

        func addProject() {
            if dataController.addProject() == false {
                showingUnlockView.toggle()
            }
        }

        /// Function called whenever the dataController changes
        /// - Parameter controller: controller
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }

        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects

            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)

            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch projects")
            }
        }
    }
}
