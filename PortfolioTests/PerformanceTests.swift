//
//  PerformanceTests.swift
//  PortfolioTests
//
//  Created by MacBook Pro on 26/12/2021.
//

import XCTest
@testable import Portfolio

class PerformanceTests: BaseTestCase {

    func testAwardCalculationPerformance() throws {
        // Create a significant amount of test data
        for _ in 1...100 {
            try dataController.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards.")
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}
