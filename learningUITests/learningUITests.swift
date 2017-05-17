//
//  learningUITests.swift
//  learningUITests
//
//  Created by Pivotal on 5/16/17.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import XCTest

class learningUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app.launchArguments = ["USE_LOCALHOST"]
        app.launch()
    }
    
    func testEmoteList() {
        let channelTextField = app.textFields["Channel"]
        channelTextField.tap()
        channelTextField.typeText("misterrogers")
        app.buttons["Return"].tap()
        channelTextField.typeText("\n")
        
        expectation(
            for: NSPredicate(format: "exists == 1"),
            evaluatedWith: app.staticTexts["PogChamp 12"],
            handler: nil
        )
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(app.staticTexts["Kappa 11"].exists)
        XCTAssert(app.staticTexts["NotLikeThis 2"].exists)
        XCTAssert(app.staticTexts["WutFace 5"].exists)
        XCTAssert(app.staticTexts["Jebaited 1"].exists)
        XCTAssert(app.staticTexts["BibleThump 1"].exists)
    }
}
