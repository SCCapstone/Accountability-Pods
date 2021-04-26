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
    /// Test if user can post an empty resource
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user doesn't enter any resource title or description and pop up appears explaining they need to add more information
    ///   - Fail: Should fail if user can post empty resource with no pop up
    func testShareEmptyPost() throws {
        let app = XCUIApplication()
        app.launch()
        
        //taps add post button
        app.navigationBars["Power Pods"]/*@START_MENU_TOKEN@*/.buttons["addPostButton"]/*[[".buttons[\"Item\"]",".buttons[\"addPostButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //attempts to post empty resource
        app/*@START_MENU_TOKEN@*/.staticTexts["Post"]/*[[".buttons[\"Post\"].staticTexts[\"Post\"]",".staticTexts[\"Post\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //tests pop up alert
        app.alerts["Need more info"].scrollViews.otherElements.buttons["Got it!"].tap()
    }
    /// Test if log out button exists when user  is signed in
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user is signed in and on home page where log out button is located
    ///   - Fail: Should fail if user is not signed in or not on home page where log out button is located
    func testLogOutButtonExists() throws {
        let app = XCUIApplication()
        app.launch()
        
        //taps logout button
        let logOutButton = app.navigationBars["Power Pods"].buttons["logOut"]
        logOutButton.tap()
        
        //test if log out button exists
        XCTAssertTrue(logOutButton.exists)
    }
    
    /// Test if settings button exists when on profile page
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user is signed in and on profile page where settings button is located
    ///   - Fail: Should fail if user is not signed in or not on profile page where settings button is located
    func testSettingsButtonExits() throws {
        let app = XCUIApplication()
        app.launch()
        
        //navigate to profile page
        let profilePage = app.tabBars["Tab Bar"].buttons["person.fill"]
        profilePage.tap()
        
        //tap settings button
        let settingsButton = app.buttons["gearshape.fill"]
        settingsButton.tap()
        
        //tests if settings button exits
        XCTAssertTrue(settingsButton.exists)
                
    }
    /// Test if user can post an empty resource
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user doesn't enter any skill title or description and pop up appears explaining they need to add more information
    ///   - Fail: Should fail if user can post empty skill with no pop up
    func testShareEmptySkill() throws {
        let app = XCUIApplication()
        app.launch()
        
        //navigate to profile page
        app.tabBars["Tab Bar"].buttons["person.fill"].tap()
        
        //navigate to skills/tap add skill
        let app2 = app
        app2/*@START_MENU_TOKEN@*/.buttons["Skills"]/*[[".segmentedControls.buttons[\"Skills\"]",".buttons[\"Skills\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app2/*@START_MENU_TOKEN@*/.buttons["Add Skill"]/*[[".segmentedControls.buttons[\"Add Skill\"]",".buttons[\"Add Skill\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //attempts too add empty skill by tapping done button
        app2/*@START_MENU_TOKEN@*/.staticTexts["Done"]/*[[".buttons[\"Done\"].staticTexts[\"Done\"]",".staticTexts[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //tests if alert that informs user they need to add information exists
        let emptySkillAlert = app.alerts["Need more info"].scrollViews.otherElements.buttons["Got it!"]
        XCTAssertTrue(emptySkillAlert.exists)
    }
    /// Test if help button exists on each tab
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user receives pop up after tapping help button(?) on each tab(home, profile, search, message)
    ///   - Fail: Should fail if user does not receive pop up after tapping help button on each tab
    func testHelpButtonOnEachTab()  throws {
        
        let app = XCUIApplication()
        app.launch()
        
        //navigate to home page -> tap help button to test if user recieves home help pop up
        app.navigationBars["Power Pods"].buttons["questionmark.circle"].tap()
        app.alerts["Home Help"].scrollViews.otherElements.buttons["Got it!"].tap()
        
        //navigate to profile page -> tap help button to test if user recieves profile help pop up
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["person.fill"].tap()
        let questionmarkCircleButton = app.buttons["questionmark.circle"]
        questionmarkCircleButton.tap()
        app.alerts["My Profile Help"].scrollViews.otherElements.buttons["Got it!"].tap()
        
        //navigate to search page -> tap help button to test if user recieves search help pop up
        tabBar.buttons["Search"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        questionmarkCircleButton.tap()
        app.alerts["Search Help"].scrollViews.otherElements.buttons["Got it!"].tap()
        
        //navigate to message page -> tap help button to test if user recieves message help pop up
        tabBar.buttons["message"].tap()
        questionmarkCircleButton.tap()
        app.alerts["Messages Help"].scrollViews.otherElements.buttons["Got it!"].tap()
        
    }
    /// Test if add contact button switches from + to - when user is already a contact
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user is already contacts with Jenny Scholz and the contact button appears to - after tap, and then + after tapping again
    ///   - Fail: Should fail if user is not already contacts with Jenny Scholz because the contact button should appear as + on first tap
    
    func testAddContactButtonSwitches() throws {
        let app = XCUIApplication()
        
        
        //navigate to search page and find Jennyscholz6
        app.tabBars["Tab Bar"].buttons["Search"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Search"]/*[[".buttons.matching(identifier: \"Search\").staticTexts[\"Search\"]",".staticTexts[\"Search\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //taps jennyscholz6 profile
        app.tables/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Jenny Scholz").element/*[[".cells.containing(.staticText, identifier:\"@jennyscholz6\").element",".cells.containing(.staticText, identifier:\"Jenny Scholz\").element"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //test if contact button switches accurately when already a contact
            //tests if contact button switches to minus after tap if user is already contacts with jennyscholz6 (unadds user)
            app.buttons["person.fill.badge.minus"].tap()
            //tests if contact button switches to plus after tap (adds user back to contacts)
            app.buttons["person.badge.plus.fill"].tap()
    }
    /// Test if tapping trash icon (delete button) triggers pop up that confirms delete on view skills
    ///
    /// - Conditions:
    ///   - Pass: Should pass if user can successfully add a skill, view skill, and then pop up confirmation appears when you tap trash icon
    ///   - Fail: Should fail if user cannot add a skill, view the skill or pop up doesnt appear when tapping trash icon
    
    func testDeleteButtonConfirmsOnSkills() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        //navigate to profile
        app.tabBars["Tab Bar"].buttons["person.fill"].tap()
        
        let app2 = app
        
        //navigate to skills -> Add Skill
        app2/*@START_MENU_TOKEN@*/.buttons["Skills"]/*[[".segmentedControls.buttons[\"Skills\"]",".buttons[\"Skills\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        app2/*@START_MENU_TOKEN@*/.buttons["Add Skill"]/*[[".segmentedControls.buttons[\"Add Skill\"]",".buttons[\"Add Skill\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //Enter filler for skill name and desc
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.children(matching: .textField).element.tap()
        element.children(matching: .textView).element.tap()
        
        //tap done to add skill
        app2/*@START_MENU_TOKEN@*/.staticTexts["Done"]/*[[".buttons.matching(identifier: \"Done\").staticTexts[\"Done\"]",".staticTexts[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //navigate to view skills
        app2/*@START_MENU_TOKEN@*/.buttons["View Skills"]/*[[".segmentedControls.buttons[\"View Skills\"]",".buttons[\"View Skills\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //tap on recently added skill
        app2.tables/*@START_MENU_TOKEN@*/.staticTexts["skill name "]/*[[".cells.staticTexts[\"skill name \"]",".staticTexts[\"skill name \"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //tap on trash icon to delete
        app.buttons["trash"].tap()
        
        //tests if alert pops up
        let deleteSkillAlert = app.alerts["Delete Skill"].scrollViews.otherElements.buttons["No"]
        deleteSkillAlert.tap()
        
    }
}
