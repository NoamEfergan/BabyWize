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

    func testCRUDfeed() throws {
        // Create
        let feed = mockFeeds.randomElement()
        let safeFeed = try XCTUnwrap(feed)
        manager.addFeed(safeFeed)
        XCTAssertEqual(manager.feedData.count, 1)

        // Update

        var firstFeed = try XCTUnwrap(manager.feedData.first)
        firstFeed.amount = 12.0
        let index = try XCTUnwrap(manager.feedData.firstIndex(where: { $0.id == firstFeed.id }))
        manager.updateFeed(firstFeed, index: index)
        XCTAssertEqual(manager.feedData.first?.amount, 12.0)

        // Remove
        let indexSet = IndexSet(manager.feedData.indices.compactMap { Int($0) })
        manager.removeFeed(at: indexSet)
        XCTAssertTrue(manager.feedData.isEmpty)
    }

    func testCRUDsleep() throws {
        // Create
        let sleep = mockSleeps.randomElement()
        let safeSleep = try XCTUnwrap(sleep)
        manager.addSleep(safeSleep)
        XCTAssertEqual(manager.sleepData.count, 1)

        // Update
        let newDate: Date = .now
        let firstSleep = try XCTUnwrap(manager.sleepData.first)
        let newSleep = Sleep(id: firstSleep.id, date: firstSleep.date, start: newDate, end: firstSleep.end)
        let index = try XCTUnwrap(manager.sleepData.firstIndex(where: { $0.id == firstSleep.id }))
        manager.updateSleep(newSleep, index: index)
        XCTAssertEqual(manager.sleepData.first?.start, newDate)

        // Remove
        let indexSet = IndexSet(manager.sleepData.indices.compactMap { Int($0) })
        manager.removeSleep(at: indexSet)
        XCTAssertTrue(manager.sleepData.isEmpty)
    }

    func testCRUDnappy() throws {
        // Create
        let change = NappyChange(id: UUID().uuidString, dateTime: .now, wetOrSoiled: .wet)
        manager.addNappyChange(change)
        XCTAssertEqual(manager.nappyData.count, 1)

        // Update
        let firstChange = try XCTUnwrap(manager.nappyData.first)
        let newChange = NappyChange(id: firstChange.id, dateTime: firstChange.dateTime, wetOrSoiled: .soiled)
        let index = try XCTUnwrap(manager.nappyData.firstIndex(where: { $0.id == firstChange.id }))
        manager.updateChange(newChange, index: index)
        XCTAssertEqual(manager.nappyData.first?.wetOrSoiled, .soiled)

        // Remove
        let indexSet = IndexSet(manager.nappyData.indices.compactMap { Int($0) })
        manager.removeChange(at: indexSet)
        XCTAssertTrue(manager.nappyData.isEmpty)
    }

    func testVerifyUniqueness() {
        let id = UUID().uuidString
        let firstFeed = Feed(id: id, date: .now, amount: 12, note: nil, solidOrLiquid: .liquid)
        let secondFeed = Feed(id: UUID().uuidString, date: .now, amount: 12, note: nil, solidOrLiquid: .liquid)
        let thirdFeed = Feed(id: id, date: .now, amount: 12, note: nil, solidOrLiquid: .liquid)

        manager.mergeFeedsWithRemote([firstFeed,secondFeed,thirdFeed])
        XCTAssertEqual(manager.feedData.count, 2)

        let firstSleep = Sleep(id: id, date: .now, start: .now, end: .now)
        let secondSleep = Sleep(id: UUID().uuidString, date: .now, start: .now, end: .now)
        let thirdSleep = Sleep(id: id, date: .now, start: .now, end: .now)

        manager.mergeSleepsWithRemote([firstSleep, secondSleep, thirdSleep])
        XCTAssertEqual(manager.sleepData.count, 2)

        let firstChange = NappyChange(id: id, dateTime: .now, wetOrSoiled: .soiled)
        let secondChange = NappyChange(id: UUID().uuidString, dateTime: .now, wetOrSoiled: .soiled)
        let thirdChange = NappyChange(id: id, dateTime: .now, wetOrSoiled: .soiled)

        manager.mergeChangesWithRemote([firstChange, secondChange, thirdChange])
        XCTAssertEqual(manager.nappyData.count, 2)
    }
}
