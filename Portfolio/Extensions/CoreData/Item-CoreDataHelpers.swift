//
//  Item-CoreDataHelpers.swift
//  Portfolio
//
//  Created by MacBook Pro on 12/11/2021.
//

import Foundation
import CoreData

extension Item {
    var itemTitle: String {
        title ?? NSLocalizedString("New Item", comment: "Create a new item.")
    }

    var itemDetail: String {
        detail ?? ""
    }

    var itemCreationDate: Date {
        creationDate ?? Date()
    }

    static var example: Item {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.title = "Example Item"
        item.detail = "This is an example item"
        item.priority = 3
        item.creationDate = Date()
        return item
    }

    enum SortOrder {
        case optimized, title, creationDate
    }
}
