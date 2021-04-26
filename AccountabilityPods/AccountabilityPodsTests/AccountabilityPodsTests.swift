//
//  AccountabilityPodsTests.swift
//  AccountabilityPodsTests
//
//  Created by MADRID, VASCO MADRID on 10/25/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import XCTest
@testable import AccountabilityPods
@testable import MessageKit

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

// MARK: - Chat View Controller Tsts

/// All the sets relating to the Chat View Controller and MessageKit Implementation
///
class ChatViewControllerTests: XCTestCase {
    
    ///mock user for MessageKit Sender Type
    struct MockUser: SenderType {
        var senderId: String
        var displayName: String
    }
    
    ///Mock structure of Message for testing
    struct MockMessage: MessageType {

        var messageId: String
            var sender: SenderType {
                return user
            }
            var sentDate: Date
            var kind: MessageKind
            var user: MockUser
        //declare the message variables
        private init(kind: MessageKind, user: MockUser, messageId: String) {
            self.kind = kind
            self.user = user
            self.messageId = messageId
            self.sentDate = Date()
        }
        //initialize message variables
        init(text: String, user: MockUser, messageId: String) {
            self.init(kind: .text(text), user: user, messageId: messageId)
        }
    }
    
    ///mock extension for MessageDataSource properties
    class MockMessagesDataSource: MessagesDataSource {

        //declare variables
        var messages: [MessageType] = []
        let senders: [MockUser] = [
            MockUser(senderId: "sender_1", displayName: "Sender 1"),
            MockUser(senderId: "sender_2", displayName: "Sender 2")
        ]

        var currentUser: MockUser {
            return senders[0]
        }

        ///SenderType for mock
        func currentSender() -> SenderType {
            return currentUser
        }

        ///override sections function
        func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
            return messages.count
        }

        ///override function
        func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
            return messages[indexPath.section]
        }
        func messageTopLabelAttributedText(for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {

            let name = message.sender.displayName
           
            return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                           .foregroundColor: UIColor(white: 0.5, alpha: 1)])
        }
        func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
                return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
            }

    }
    
    //class variables
    var sut: ChatViewController!
    var messages: [MessageType] = []
    var senders: [MockUser] = []
 
    // MARK: - Overridden Methods
    override func setUp() {
        super.setUp()
        //initialize variables
        sut = ChatViewController()
        _ = sut.view
        sut.beginAppearanceTransition(true, animated: true)
        sut.endAppearanceTransition()
        sut.view.layoutIfNeeded()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }
    ///make mock messages for testing
    private func makeMessages() -> [MessageType] {
            return [ Message(id: "test_id", content: "Test", created: 1, senderID: "sender_1", senderName: "Sender 1", showMsg: true, showMsg1: true),
                     Message(id: "test_id2", content: "Test 2", created: 2, senderID: "sender_2", senderName: "Sender 2", showMsg: true, showMsg1: true)]
        }

    // MARK: - Chat Controller Tests
    
    ///Checks the number of sections without data is equal to zero
    func testNumberOfEmptySection() {

        XCTAssertEqual(sut.messagesCollectionView.numberOfSections, 0)
    }
    
    ///check Sections match Messages Array
    func testNumberOfSection_isNumberOfMessages() {
            let messagesDataSource = MockMessagesDataSource()
            sut.messagesCollectionView.messagesDataSource = messagesDataSource
            messages = makeMessages()

            sut.messagesCollectionView.reloadData()

            let count = sut.messagesCollectionView.numberOfSections
            let expectedCount = messagesDataSource.numberOfSections(in: sut.messagesCollectionView)

            XCTAssertEqual(count, expectedCount)
    }

    ///Check Number of Items In Section Returns correct value of 1
    func testNumberOfItemInSection() {
        let messagesDataSource = MockMessagesDataSource()
            sut.messagesCollectionView.messagesDataSource = messagesDataSource
            messagesDataSource.messages = makeMessages()

            sut.messagesCollectionView.reloadData()

            XCTAssertEqual(sut.messagesCollectionView.numberOfItems(inSection: 0), 1)
            XCTAssertEqual(sut.messagesCollectionView.numberOfItems(inSection: 1), 1)
        }

    ///Test Message Collection View has subview of the needed Messages Collection View
    func testSubviewsSetup() {
            let controller = ChatViewController()
            XCTAssertTrue(controller.view.subviews.contains(controller.messagesCollectionView))
    }
    
    ///Test Set Up View is Correct
    func testDelegateAndDataSourceSetup() {
            let controller = ChatViewController()
            controller.view.layoutIfNeeded()
            XCTAssertTrue(controller.messagesCollectionView.delegate is MessagesViewController)
            XCTAssertTrue(controller.messagesCollectionView.dataSource is MessagesViewController)
        }
    
    ///Test TextMessage Data is the correct data
    func testCellIsTextData() {
        let msg = Message(id: "test_id", content: "Test", created: 1, senderID: "sender_1", senderName: "Sender 1", showMsg: true, showMsg1: true)
            sut.messages.append(msg)

            sut.messagesCollectionView.reloadData()

            let cell = sut.messagesCollectionView.dataSource?.collectionView(sut.messagesCollectionView, cellForItemAt: IndexPath(item: 0, section: 0))

            XCTAssertNotNil(cell)
            XCTAssertTrue(cell is TextMessageCell)
        }
}

