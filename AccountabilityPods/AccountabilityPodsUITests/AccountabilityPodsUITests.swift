//
//  AccountabilityPodsUITests.swift
//  AccountabilityPodsUITests
//
//  Created by MADRID, VASCO MADRID on 10/25/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import XCTest

class AccountabilityPodsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    /*
     UI test for logging in
     - tests if log in button takes user to login screen
     - tests if user can enter values in text fields
     - tests if known account information takes user to home screen
     */
    func testLoggingIn() throws {
        let app = XCUIApplication()
        app.launch()
        // tap login button
        let loginButton = app.buttons["loginButton"]
        loginButton.tap() // takes user to log in view
        
        // test if user can enter email
        let emailTextField = app.textFields["emailTextField"]
        let passwordTextField = app.textFields["passwordTextField"]
        let email = "testaccount@test.com" // known email account
        let password = "Password!123" // known password
        
        // test email input
        emailTextField.tap()
        emailTextField.typeText(email)
        XCTAssertEqual(emailTextField.value as! String , email)
        
        // test password input
        passwordTextField.tap()
        passwordTextField.typeText(password)
        XCTAssertEqual(passwordTextField.value as! String, password)
        
        // test enter button
        let enterButton = app.buttons["enterButton"]
        enterButton.tap() // takes user to screen
        
        // tests if homescreen is shown
        let addPostButton = app.buttons["addPostButton"]
        XCTAssertTrue(addPostButton.exists)
    }
}
