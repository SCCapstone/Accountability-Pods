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
    
    
    /// Tests if the login button appears
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user is not already logged
    ///   - Fail: Should fail if user is already logged in
    func testLoginButtonExists() throws {
        let app = XCUIApplication()
        // launch app
        app.launch()
        // return true if login button exists
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
    }
    
    /// Test if login button takes you to the login screen
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user is not already logged
    ///   - Fail: Should fail if user is already logged in
    func testLoginButtonTaketoLoginScreen() throws {
        let app = XCUIApplication()
        app.launch()
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()
        let emailTextField = app.textFields["emailTextField"]
        XCTAssertTrue(emailTextField.exists)
    }
    
    /// Test if create account button exists when app is first opened
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user is not already logged
    ///   - Fail: Should fail if user is already logged in
    func testCreateAccountButtonExists() throws {
        let app = XCUIApplication()
        app.launch()
        let caButton = app.buttons["caButton"]
        XCTAssertTrue(caButton.exists)
    }
    
    /// Test if create account button takes you to create account page
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user is not already logged
    ///   - Fail: Should fail if user is already logged in
    func testCreateAccountTakeToCAScreen() throws {
        let app = XCUIApplication()
        app.launch()
        let loginButton = app.buttons["caButton"]
        loginButton.tap()
        let unTextField = app.textFields["usernameTextField"]
        XCTAssertTrue(unTextField.exists)
    }
    
    /// Test if user can log in with test account
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user is not already logged
    ///   - Fail: Should fail if user is already logged in
    func testLoggingIn() throws {
        let app = XCUIApplication()
        app.launch()
        // tap login button
        let loginButton = app.buttons["loginButton"]
        loginButton.tap() // takes user to log in view
        
        // test if user can enter email
        let emailTextField = app.textFields["emailTextField"]
        
        let email = "tester@email.com" // known email account
        let password = "Password!123" // known password
        
        // test email input
        emailTextField.tap()
        emailTextField.typeText(email)
        XCTAssertEqual(emailTextField.value as! String , email)
        // tap out of keyboard
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        // test password input
        let passwordTextField = app/*@START_MENU_TOKEN@*/.secureTextFields["lpasswordTextField"]/*[[".secureTextFields[\"Password\"]",".secureTextFields[\"lpasswordTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        passwordTextField.tap()
        passwordTextField.typeText(password)
        
        // test enter button
        let enterButton = app.buttons["enterButton"]
        enterButton.tap() // takes user to screen
        
    }
    
}
