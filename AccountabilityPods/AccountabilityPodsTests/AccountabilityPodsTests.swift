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

class ChatViewControllerTests: XCTestCase {
    
    struct MockUser: SenderType {
        var senderId: String
        var displayName: String
    }
    
    /*struct MockMessage: MessageType {

        var messageId: String
        var sender: SenderType {
            return user
        }
        var sentDate: Date
        var kind: MessageKind
        var user: MockUser

        private init(kind: MessageKind, user: MockUser, messageId: String) {
            self.kind = kind
            self.user = user
            self.messageId = messageId
            self.sentDate = Date()
        }

        init(text: String, user: MockUser, messageId: String) {
            self.init(kind: .text(text), user: user, messageId: messageId)
        }

        init(attributedText: NSAttributedString, user: MockUser, messageId: String) {
            self.init(kind: .attributedText(attributedText), user: user, messageId: messageId)
        }
    }*/
    
    class MockMessagesDataSource: MessagesDataSource {

        var messages: [MessageType] = []
        let senders: [MockUser] = [
            MockUser(senderId: "sender_1", displayName: "Sender 1"),
            MockUser(senderId: "sender_2", displayName: "Sender 2")
        ]

        var currentUser: MockUser {
            return senders[0]
        }

        func currentSender() -> SenderType {
            return currentUser
        }

        func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
            return messages.count
        }

        func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
            return messages[indexPath.section]
        }

    }
    var sut: ChatViewController!
    // swiftlint:disable weak_delegate
    //private var layoutDelegate = MockLayoutDelegate()
    // swiftlint:enable weak_delegate
    // MARK: - Overridden Methods
    override func setUp() {
        super.setUp()

        sut = ChatViewController()
        //sut.messagesCollectionView.messagesLayoutDelegate = layoutDelegate
       // sut.messagesCollectionView.messagesDisplayDelegate = layoutDelegate
        _ = sut.view
        sut.beginAppearanceTransition(true, animated: true)
        sut.endAppearanceTransition()
        sut.view.layoutIfNeeded()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }
    /*private func makeMessages(for senders: [MockUser]) -> [MessageType] {
            return [MockMessage(text: "Text 1", user: senders[0], messageId: "test_id_1"),
                    MockMessage(text: "Text 2", user: senders[1], messageId: "test_id_2")]
        }*/

    // MARK: - Test
    func testNumberOfSectionWithoutData_isZero() {
        let messagesDataSource = MockMessagesDataSource()
        sut.messagesCollectionView.messagesDataSource = messagesDataSource

        XCTAssertEqual(sut.messagesCollectionView.numberOfSections, 0)
    }
    /*func testNumberOfSection_isNumberOfMessages() {
            let messagesDataSource = MockMessagesDataSource()
            sut.messagesCollectionView.messagesDataSource = messagesDataSource
            messagesDataSource.messages = makeMessages(for: messagesDataSource.senders)

            sut.messagesCollectionView.reloadData()

            let count = sut.messagesCollectionView.numberOfSections
            let expectedCount = messagesDataSource.numberOfSections(in: sut.messagesCollectionView)

            XCTAssertEqual(count, expectedCount)
        }

        func testNumberOfItemInSection_isOne() {
            let messagesDataSource = MockMessagesDataSource()
            sut.messagesCollectionView.messagesDataSource = messagesDataSource
            messagesDataSource.messages = makeMessages(for: messagesDataSource.senders)

            sut.messagesCollectionView.reloadData()

            XCTAssertEqual(sut.messagesCollectionView.numberOfItems(inSection: 0), 1)
            XCTAssertEqual(sut.messagesCollectionView.numberOfItems(inSection: 1), 1)
        }

        func testCellForItemWithTextData_returnsTextMessageCell() {
            let messagesDataSource = MockMessagesDataSource()
            sut.messagesCollectionView.messagesDataSource = messagesDataSource
            messagesDataSource.messages.append(MockMessage(text: "Test",
                                                           user: messagesDataSource.senders[0],
                                                           messageId: "test_id"))

            sut.messagesCollectionView.reloadData()

            let cell = sut.messagesCollectionView.dataSource?.collectionView(sut.messagesCollectionView,
                                                                             cellForItemAt: IndexPath(item: 0, section: 0))

            XCTAssertNotNil(cell)
            XCTAssertTrue(cell is TextMessageCell)
        }

        func testCellForItemWithAttributedTextData_returnsTextMessageCell() {
            let messagesDataSource = MockMessagesDataSource()
            sut.messagesCollectionView.messagesDataSource = messagesDataSource
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.outgoingMessageLabel]
            let attriutedString = NSAttributedString(string: "Test", attributes: attributes)
            messagesDataSource.messages.append(MockMessage(attributedText: attriutedString,
                                                           user: messagesDataSource.senders[0],
                                                           messageId: "test_id"))

            sut.messagesCollectionView.reloadData()

            let cell = sut.messagesCollectionView.dataSource?.collectionView(sut.messagesCollectionView,
                                                                             cellForItemAt: IndexPath(item: 0, section: 0))

            XCTAssertNotNil(cell)
            XCTAssertTrue(cell is TextMessageCell)
        }*/
}

