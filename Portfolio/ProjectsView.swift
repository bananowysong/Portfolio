//
//  ProjectView.swift
//  Portfolio
//
//  Created by MacBook Pro on 12/11/2021.
//

import SwiftUI

struct ProjectsView: View {
    let showClosedProjects: Bool
    let projects: FetchRequest<Project>
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationView {
            List {
                ForEach(projects.wrappedValue) { project in
                    Section(header: ProjectHeaderView(project: project)) {
                        ForEach(project.projectItems) { item in
                            ItemRowView(item: item)
                        }
                        .onDelete { offsets in
                            let allItems = project.projectItems


                            for offset in offsets {
                                let item = allItems[offset]
                                dataController.delete(item)
                            }

                            dataController.save()
                        }

                        if showClosedProjects == false {
                            Button {
                                withAnimation {
                                    let item = Item(context: moc)
                                    item.project = project
                                    item.creationDate = Date()
                                    dataController.save()
                                }
                            } label: {
                                Label("Add new Item", systemImage: "plus")
                            }
                        }
                    }
                    
                }

            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                if showClosedProjects == false {
                    Button {
                        withAnimation {
                            let project = Project(context: moc)
                            project.closed = false
                            project.creationDate = Date()
                            dataController.save()
                        }
                    } label: {
                        Label("Add project", systemImage: "plus")
                    }
                }
            }
        }
    }

    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects

        projects = FetchRequest<Project>(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)], predicate: NSPredicate(format: "closed = %d", showClosedProjects))
    }

    func items(for project: Project) -> [Item] {
        []
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
