//
//  BabyTrackerTests.swift
//  BabyTrackerTests
//
//  Created by Noam Efergan on 17/07/2022.
//

@testable import BabyTracker
import XCTest

final class BabyTrackerTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_random_date_generation() {
        for _ in 0 ... 10 {
            print(Date.getRandomMockDate())
        }
    }
}
