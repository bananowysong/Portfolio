//
//  Project-CoreDataHelpers.swift
//  Portfolio
//
//  Created by MacBook Pro on 12/11/2021.
//

import CoreData
import SwiftUI
import CloudKit

extension Project {
    var projectTitle: String {
        title ?? NSLocalizedString("New Project", comment: "Create a new project")
    }

    var projectDetail: String {
        detail ?? ""
    }

    var projectColor: String {
        color ?? "Light Blue"
    }

    var projectItemsDefaultSorted: [Item] {
         projectItems.sorted { first, second in
            if first.completed == false {
                if second.completed == true {
                    return true
                }
            } else if first.completed == true {
                if second.completed == false {
                    return false
                }
            }

            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }

            return first.itemCreationDate < second.itemCreationDate
        }
    }

    var projectItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard originalItems.isEmpty == false else { return 0 }

        let completedItems = originalItems.filter(\.completed)
        return Double(completedItems.count) / Double(originalItems.count)
    }

    static let colors = ["Pink",
                         "Purple",
                         "Red",
                         "Orange",
                         "Gold",
                         "Green",
                         "Teal",
                         "Light Blue",
                         "Dark Blue",
                         "Midnight",
                         "Dark Gray",
                         "Gray"]

    static var example: Project {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let project = Project(context: viewContext)
        project.title = "Example Project"
        project.detail = "This is an example project"
        project.closed = true
        project.creationDate = Date()
        return project
    }

    func projectItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
        case .title:
            return projectItems.sorted(by: \Item.itemTitle)
        case .creationDate:
            return projectItems.sorted(by: \Item.itemCreationDate)
        case .optimized:
            return projectItemsDefaultSorted
        }
    }

    var label: LocalizedStringKey {
        // swiftlint:disable:next line_length
        LocalizedStringKey("\(projectTitle), \(projectItems.count) items \(completionAmount * 100, specifier: "%g")% complete.")
    }

    // Converts all project data into CloudKit CKRecords
    func prepareCloudRecords(owner: String) -> [CKRecord] {
        // using CoreData Object ID as ID for the CKRecord
        let parentName = objectID.uriRepresentation().absoluteString
        let parentID = CKRecord.ID(recordName: parentName)

        // recordType is an analogue to entity in CoreData, it is stringly typed
        let parent = CKRecord(recordType: "Project", recordID: parentID)

        // writing data using dictionary syntax
        parent["title"] = projectTitle
        parent["detail"] = projectDetail
        parent["owner"] = owner
        parent["closed"] = closed

        // creating the records for items in project by mapping sorted items
        var records = projectItemsDefaultSorted.map { item -> CKRecord in
            let childName = item.objectID.uriRepresentation().absoluteString
            let childID = CKRecord.ID(recordName: childName)
            let child = CKRecord(recordType: "Item", recordID: childID)
            child["title"] = item.itemTitle
            child["detail"] = item.itemDetail
            child["completed"] = item.completed

            // links current item and its owner (project). .deleteSelf for cascade deletion
            child["project"] = CKRecord.Reference(recordID: parentID, action: .deleteSelf)
            return child
        }

        // send all the items + project as one array
        records.append(parent)
        return records
    }

    func checkCloudStatus(_ completion: @escaping (Bool) -> Void) {
        let name = objectID.uriRepresentation().absoluteString
        let id = CKRecord.ID(recordName: name)

        // For performance reasons CKFetchRecordsOperation is used - because
        // it asks for specific records based on their ID, and does not use any Predicate
        // we use [ID] in desired keys only so that it returns faster (deosnt have to
        // return data in other fields)
        let operation = CKFetchRecordsOperation(recordIDs: [id])
        operation.desiredKeys = ["recordID"]

        operation.fetchRecordsCompletionBlock = { records, _ in
            if let records = records {
                // if there is 1 record the completion handler will be called with true, otherwise false
                completion(records.count == 1)
            } else {
                completion(false)
            }
        }
        CKContainer.init(identifier: "iCloud.iam.mrnoone.portfolio").publicCloudDatabase.add(operation)
    }
}
