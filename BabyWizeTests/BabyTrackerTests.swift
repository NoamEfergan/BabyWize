//
//  BabyWizeTests.swift
//  BabyWizeTests
//
//  Created by Noam Efergan on 17/07/2022.
//

@testable import BabyWize
import XCTest

final class BabyWizeTests: XCTestCase {
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
