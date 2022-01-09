//
//  SharedProjectsView.swift
//  Portfolio
//
//  Created by MacBook Pro on 08/01/2022.
//

import SwiftUI
import CloudKit

struct SharedProjectsView: View {
    static let tag: String? = "Community"

    @State private var projects = [SharedProject]()
    @State private var loadState = LoadState.inactive

    var body: some View {
        NavigationView {
            Group {
                switch loadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No results")
                case .success:
                    List(projects) { project in
                        NavigationLink(destination: SharedItemsView(project: project)) {
                            VStack(alignment: .leading) {
                                Text(project.title)
                                    .font(.headline)
                                Text(project.owner)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Shared Projects")
        }
        .onAppear(perform: fetchSharedProjects)
    }

    func fetchSharedProjects() {
        // makes sure this will fired only once
        guard loadState == .inactive else { return }
        loadState = .loading

        let pred = NSPredicate(value: true)
        // key seems to be different to what dashboard has
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Project", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        // if desiredKeys are not set then CloudKit fetches everything
        operation.desiredKeys = ["title", "detail", "owner", "closed"]
        operation.resultsLimit = 50

        // called every time one item is fetched
        operation.recordFetchedBlock = { record in
            let id = record.recordID.recordName
            let title = record["title"] as? String ?? "No Title"
            let detail = record["detail"] as? String ?? ""
            let owner = record["owner"] as? String ?? "No owner"
            let closed = record["closed"] as? Bool ?? false

            let sharedProject = SharedProject(id: id, title: title, detail: detail, owner: owner, closed: closed)
            projects.append(sharedProject)
            loadState = .success
        }

        // called when all records are fetched
        operation.queryCompletionBlock = { _, _ in
            if projects.isEmpty {
                loadState = .noResults
            }
        }

        // send operaton to iCloud
        CKContainer.init(identifier: "iCloud.iam.mrnoone.portfolio").publicCloudDatabase.add(operation)
    }
}

struct SharedProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedProjectsView()
    }
}
