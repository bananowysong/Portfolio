//
//  PortfolioTests.swift
//  PortfolioTests
//
//  Created by MacBook Pro on 25/12/2021.
//

import XCTest
import CoreData
@testable import Portfolio

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
