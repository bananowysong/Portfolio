//
//  PortfolioUITests.swift
//  PortfolioUITests
//
//  Created by MacBook Pro on 26/12/2021.
//

import XCTest
@testable import Portfolio

class PortfolioUITests: XCTestCase {
    var app: XCUIApplication!

    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    func testAppHas4Tabs() {
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }

    func testOpenTabAddsProjects() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially")

        for tapCount in 1...5 {
            app.buttons["Add Project"].tap()
            XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) rows(s) in the list.")
        }
    }

    // Goes to open projects and adds one project and one item
    func testAddingItemInsertRows() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 rows(s) in the list.")

        app.buttons["Add New Item"].tap()
        XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
    }

    func testEditingProjectUpdatesCorrectly() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 rows(s) in the list.")

        app.buttons["New Project"].tap()
        app.textFields["Project name"].tap()

        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()

        XCTAssertTrue(app.buttons["New Project 2"].exists, "The new project name should be visible in the list.")
    }

    func testEditingItemUpdatesCorrectly() {
        testAddingItemInsertRows()

        app.buttons["New Item"].tap()

        app.textFields["Item name"].tap()
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()

        XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item name should be visible in the list.")
    }

    func testAllAwardsShowLockedAlert() {
        app.buttons["Awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }

    func testOpeningAndClosingProject() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 rows(s) in the list.")

        app.buttons["New Project"].tap()
        app.buttons["Close this project"].tap()

        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows after cloing project")

        app.buttons["Closed"].tap()
        XCTAssertTrue(app.buttons["New Project"].exists, "The button should exist")

    }

//    func testUnlockingAward() {
//        app.buttons["Awards"].tap()
//        guard let firstAward = app.scrollViews.buttons.allElementsBoundByIndex.first else {
//            fatalError()
//        }
//
//        firstAward.tap()
//        XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
//        app.buttons["OK"].tap()
//        app.buttons["Open"].tap()
//        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially")
//
//        app.buttons["Add Project"].tap()
//        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 rows(s) in the list.")
//
//        app.buttons["Add New Item"].tap()
//        XsCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
//
//        app.buttons["Awards"].tap()
//        app.scrollViews.buttons.allElementsBoundByIndex.first!.tap()
//        XCTAssertTrue(app.alerts["Unlocked: First Steps"].exists, "The first award should be unlocked.")
//    }

    func testSwipeToDeleteWorks() {
        testAddingItemInsertRows()
        app.buttons["New Item"].swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after deletion.")
    }
}
