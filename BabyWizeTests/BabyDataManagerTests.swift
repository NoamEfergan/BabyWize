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
    let mockSleeps = PlaceholderChart.MockData.mockSleep
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
        manager.updateFeed(firstFeed, index: index, updateRemote: false)
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
        manager.updateSleep(newSleep, index: index, updateRemote: false)
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
        manager.updateChange(newChange, index: index, updateRemote: false)
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

    func testRemoveAll() {
        let id = UUID().uuidString
        let firstFeed = Feed(id: id, date: .now, amount: 12, note: nil, solidOrLiquid: .liquid)
        let secondFeed = Feed(id: UUID().uuidString, date: .now, amount: 12, note: nil, solidOrLiquid: .liquid)
        let thirdFeed = Feed(id: id, date: .now, amount: 12, note: nil, solidOrLiquid: .liquid)

        manager.mergeFeedsWithRemote([firstFeed,secondFeed,thirdFeed])
        manager.removeAll(for: .liquidFeed)
        XCTAssertEqual(manager.feedData.count, 0)

        let firstSleep = Sleep(id: id, date: .now, start: .now, end: .now)
        let secondSleep = Sleep(id: UUID().uuidString, date: .now, start: .now, end: .now)
        let thirdSleep = Sleep(id: id, date: .now, start: .now, end: .now)

        manager.mergeSleepsWithRemote([firstSleep, secondSleep, thirdSleep])
        manager.removeAll(for: .sleep)
        XCTAssertEqual(manager.sleepData.count, 0)

        let firstChange = NappyChange(id: id, dateTime: .now, wetOrSoiled: .soiled)
        let secondChange = NappyChange(id: UUID().uuidString, dateTime: .now, wetOrSoiled: .soiled)
        let thirdChange = NappyChange(id: id, dateTime: .now, wetOrSoiled: .soiled)

        manager.mergeChangesWithRemote([firstChange, secondChange, thirdChange])
        manager.removeAll(for: .nappy)
        XCTAssertEqual(manager.nappyData.count, 0)
    }

    func testLastFeed() {
        let firstFeed = Feed(id: UUID().uuidString, date: .now, amount: 11, note: nil, solidOrLiquid: .liquid)
        let secondFeed = Feed(id: UUID().uuidString, date: .now, amount: 12, note: nil, solidOrLiquid: .liquid)
        let thirdFeed = Feed(id: UUID().uuidString, date: .now, amount: 13, note: nil, solidOrLiquid: .liquid)
        manager.mergeFeedsWithRemote([firstFeed,secondFeed,thirdFeed])
        XCTAssertEqual(manager.lastFeedString, thirdFeed.amount.liquidFeedDisplayableAmount())
    }

    func testLastSleep() {
        let firstStart = Date.getRandomMockDate()
        let firstEnd = Date.getRandomEndData(from: firstStart)

        let firstSleep = Sleep(id: UUID().uuidString, date: .now, start: .now, end: .now)
        let secondSleep = Sleep(id: UUID().uuidString, date: .now, start: .now, end: .now)
        let thirdSleep = Sleep(id: UUID().uuidString, date: .now, start: firstStart, end: firstEnd)

        manager.mergeSleepsWithRemote([firstSleep, secondSleep, thirdSleep])
        XCTAssertEqual(manager.lastSleepString, thirdSleep.getDisplayableString())
    }

    func testBiggestSmallestAndAverageFeed() {
        let firstFeed = Feed(id: UUID().uuidString, date: .now, amount: 10, note: nil, solidOrLiquid: .liquid)
        let secondFeed = Feed(id: UUID().uuidString, date: .now, amount: 20, note: nil, solidOrLiquid: .liquid)
        manager.mergeFeedsWithRemote([firstFeed,secondFeed])
        XCTAssertEqual(manager.getAverage(for: .liquidFeed), 15.displayableAmount(isSolid: false))
        XCTAssertEqual(manager.getBiggest(for: .liquidFeed), 20.displayableAmount(isSolid: false))
        XCTAssertEqual(manager.getSmallest(for: .liquidFeed), 10.displayableAmount(isSolid: false))
    }

    func getBiggestSmallestAndAverageSleep() throws {
        let formatter = ISO8601DateFormatter()
        let firstDate = try XCTUnwrap(formatter.date(from:"2022-12-19T14:15:27+0000"))
        let secondDate = try XCTUnwrap(formatter.date(from:"2022-12-19T16:15:27+0000"))

        let thirdDate = try XCTUnwrap(formatter.date(from:"2022-12-19T17:15:27+0000"))
        let forthDate = try XCTUnwrap(formatter.date(from:"2022-12-19T18:15:27+0000"))

        let firstSleep = Sleep(id: UUID().uuidString, date: .now, start: firstDate, end: secondDate)
        let secondSleep = Sleep(id: UUID().uuidString, date: .now, start: thirdDate, end: forthDate)

        let hour = TimeInterval(60 * 60)
        let twoHours = hour * 2
        let hourAndAHalf = hour * 1.5

        manager.mergeSleepsWithRemote([firstSleep, secondSleep])
        XCTAssertEqual(manager.getBiggest(for: .sleep), twoHours.hourMinuteSecondMS)
        XCTAssertEqual(manager.getSmallest(for: .sleep), hour.hourMinuteSecondMS)
        XCTAssertEqual(manager.getAverage(for: .sleep), hourAndAHalf.hourMinuteSecondMS)
    }
}
