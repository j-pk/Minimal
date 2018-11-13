//
//  MainListingDelegateTests.swift
//  MinimalTests
//
//  Created by Jameson Kirby on 11/12/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import XCTest
@testable import Minimal

class MainListingDelegateTests: XCTestCase {

    var database: MockDatabaseEngine?
    
    override func setUp() {
        database = MockDatabaseEngine()
        database?.setup()
    }

    override func tearDown() {
        database = nil
    }

    func testBuildControllerForRecentlyViewedSubreddits() {
        let expectation = XCTestExpectation(description: "Build Controller Delegate Completed")
        let model = MainModel(database: database!, delegate: MockMainViewController(expectation: expectation))
        model.updateUserAndListings(forSubreddit: nil, subredditId: "t3_9tjv5z", category: .hot, timeFrame: nil)
        
        wait(for: [expectation], timeout: 3)
        model.buildControllerForRecentlyViewedSubreddits()
    }
    
    func testLastViewedSubreddit() {
        let expectation = XCTestExpectation(description: "Last Viewed Delegate Completed")
        let model = MainModel(database: database!, delegate: MockMainViewController(expectation: expectation))
        model.updateUserAndListings(forSubreddit: nil, subredditId: "t3_9tjv5z", category: .hot, timeFrame: nil)
    
        wait(for: [expectation], timeout: 3)
        model.fetchLastViewedSubredditData()
    }
    
    func testBuildControllerForCategoryandTimeframe() {
        let expectation = XCTestExpectation(description: "Last Viewed Delegate Completed")
        let model = MainModel(database: database!, delegate: MockMainViewController(expectation: expectation))
        model.buildControllerForCategoryAndTimeframe()

        wait(for: [expectation], timeout: 3)
    }
}

class MockMainViewController: MainListingDelegate {
    var expectation: XCTestExpectation
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    func lastViewedSubreddit(data: (subreddit: String, categoryAndTimeFrame: String)) {
        XCTAssertEqual(data.subreddit, "r/EarthPorn", "Passed: Subreddit String for Update User and Listings")
        XCTAssertEqual(data.categoryAndTimeFrame, "Hot", "Passed: Category And TimeFrame String for Update User and Listings")
        expectation.fulfill()
    }
    
    func presentRecentViewedSubreddits(with controller: UIAlertController) {
        XCTAssert(controller.actions.count >= 1)
        expectation.fulfill()
    }
    
    func presentCategotyAndTime(with controller: UIAlertController) {
        XCTAssert(controller.actions.count == CategorySortType.allCases.count)
        expectation.fulfill()
    }
    
    func updateViewWithRequestedListings(for subreddit: String, with categoryAndTimeFrame: String) {
        XCTAssertEqual(subreddit, "r/EarthPorn", "Passed: Subreddit String for Update User and Listings")
        XCTAssertEqual(categoryAndTimeFrame, "Hot", "Passed: Category And TimeFrame String for Update User and Listings")
        expectation.fulfill()
    }
}
