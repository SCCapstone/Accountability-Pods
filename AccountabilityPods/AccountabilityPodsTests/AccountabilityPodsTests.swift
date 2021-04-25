//
//  AccountabilityPodsTests.swift
//  AccountabilityPodsTests
//
//  Created by MADRID, VASCO MADRID on 10/25/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import XCTest
@testable import AccountabilityPods

class AccountabilityPodsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
//unit testing sign up view controller
class SignUpViewTests: XCTestCase {
    //system under test sign up view controller
    var sut: SignUpViewController!
    
    //to access UI elements instantiate and load View controller
    override func setUpWithError() throws {
        //set up screen testing
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "SignUpViewController") as? SignUpViewController
        //loads the correct view control since not intial
        sut.loadViewIfNeeded()
    }
    
    //release resources
    override func tearDownWithError() throws {
        sut = nil
    }
    
    //test space holder indicate the correct information user is required to input in all textfields
    func testSignUpFillersLoad(){
        XCTAssertEqual("First Name", sut.firstnameTextField!.placeholder!)
        XCTAssertEqual("Last Name", sut.lastnameTextField!.placeholder!)
        XCTAssertEqual("Email", sut.emailTextField!.placeholder!)
        XCTAssertEqual("Password", sut.passwordTextField!.placeholder!)
    }
    
    //test required email content type is set for email text field
    func testEmailTextFieldContent() throws{
        //if content type of textfiled is changed in main storyboard this test will fail
        let emailText = try XCTUnwrap(sut.emailTextField, "Email address not connected")
        
        XCTAssertEqual(emailText.textContentType, UITextContentType.emailAddress, "Email Address Textfiled does not have an Email address content type")
        
    }
    
    //test if create account UIButton is Connected and has Action
    func testCreateAccountButtonHasaction() {
        let accountButton: UIButton = sut.createAccountButton
        //check button exists
        XCTAssertNotNil(accountButton, "View Controller does not have UIBotton create account")
        
        //read all actions associated with the button
        guard let accountButtonActions = accountButton.actions(forTarget: sut, forControlEvent: .touchUpInside) else {
            XCTFail("UIButton does not have actions assigned for Control Event")
            return
        }
        
        //check specific createAccountTapped method is an action from button
        XCTAssertTrue(accountButtonActions.contains("createAccountTapped:"))
        
    }
}
