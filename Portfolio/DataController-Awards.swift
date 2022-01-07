//
//  DataController-Awards.swift
//  Portfolio
//
//  Created by MacBook Pro on 02/01/2022.
//

import CoreData

extension DataController {
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {

        // returns true if they added a certain number of items
        case "items":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        // returns true if they completed a certain number of items
        case "complete":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        // an unknown award criterion; this should never be allowed
        default:
            // fatalError("Unknown award criterion \(award.criterion).")
            return false
        }
    }
}
