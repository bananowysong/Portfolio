//
//  AssetTests.swift
//  PortfolioTests
//
//  Created by MacBook Pro on 25/12/2021.
//

import XCTest
@testable import Portfolio

class AssetTests: XCTestCase {
    func testColorsExist() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from assets catalog.")
        }
    }

    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from Json")
    }
}
