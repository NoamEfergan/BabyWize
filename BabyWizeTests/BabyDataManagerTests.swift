//
//  BabyDataManagerTests.swift
//  BabyWizeTests
//
//  Created by Noam Efergan on 19/12/2022.
//

@testable import BabyWize
import FirebaseAuth
import XCTest

final class BabyDataManagerTests: XCTestCase {
    var manager: BabyDataManager!
    let mockFeeds = PlaceholderChart.MockData.mockFeed
    let mockSleeps = PlaceholderChart.MockData.getMockSleep()
    override func setUpWithError() throws {
        let container = ContainerBuilder.buildMockContainer()
        Resolver.shared.setDependencyContainer(container)
        manager = Resolver.shared.resolve(BabyDataManager.self)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialValues() {
        XCTAssertTrue(manager.feedData.isEmpty)
        XCTAssertTrue(manager.sleepData.isEmpty)
        XCTAssertTrue(manager.nappyData.isEmpty)
    }

    func testAddingFeed() throws {
        let feed = mockFeeds.randomElement()
        let safeFeed = try XCTUnwrap(feed)
        manager.addFeed(safeFeed)
        XCTAssertEqual(manager.feedData.count, 1)
    }
}
