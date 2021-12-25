//
//  ExtensionTests.swift
//  PortfolioTests
//
//  Created by MacBook Pro on 25/12/2021.
//

import XCTest
@testable import Portfolio
import SwiftUI

class ExtensionTests: XCTestCase {

    func testSequenceKeyPathSortingSelf() {
        let items = [1, 4, 3, 2, 5]
        let sortedItems = items.sorted(by: \.self)
        XCTAssertEqual(sortedItems, [1, 2, 3, 4, 5], "The sorted numbers must be ascending.")
    }

    func testSequenceKeyPathSortingCustom() {
        struct TestType: Equatable {
            var value: String
        }

        let value1 = TestType(value: "d")
        let value2 = TestType(value: "a")
        let value3 = TestType(value: "c")
        let items = [value1, value2, value3]

        let sortedItems = items.sorted(by: \TestType.value, using: >)

        XCTAssertEqual(
            sortedItems,
            [value1, value3, value2],
            "The sorted numbers must be ascending."
        )
    }

    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode([Award].self, from: "Awards.json")
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non empty array")
    }

    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)

        let data = bundle.decode(String.self, from: "DecodableString.json")
        XCTAssertEqual(data, "The rain in Spain falls mainly on the Spaniards.", "The string must match the content of DecodableString.json.")// swiftlint:disable:this line_length
    }

    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)

        let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
        XCTAssertEqual(data.count, 3, "There should be three items decoded from DecodableDictionary.json.")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain Int to String mappings.")
    }

    func testBindingOnChange() {
        // Given
        var onChangeFunctionRun = false

        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }

        var storedValue = ""

        let binding = Binding(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let changedBinding = binding.onChange(exampleFunctionToCall)

        // When
        changedBinding.wrappedValue = "Test"

        // Then
        XCTAssertTrue(onChangeFunctionRun, "The onChange() function was not run.")
    }
}
