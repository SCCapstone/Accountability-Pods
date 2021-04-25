//
//  ChatViewController.swift
//  AccountabilityPods
//
//  Created by KAHAN-THOMAS, JHADA L on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
import UIKit
import Firebase
import FirebaseFirestore
import MessageKit
import InputBarAccessoryView
import IQKeyboardManagerSwift


// MARK: - Struct Data Types for Chat and Messages

//Chat struct to store conversation relationship of users
struct Chat {
    var users: [String]
    
    var dictionary: [String: Any] {
        return ["users": users]
    }
}

/// Extension to initialize chat variables
extension Chat {
    init?(dictionary: [String:Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else {
            return nil
        }
        self.init(users: chatUsers)
    }
}

//Message struct encapsulates properties of a message and dictionary to return
struct Message {
    var id: String
    var content: String
    var created: Int64
    var senderID: String
    var senderName: String
    var showMsg: Bool
    var showMsg1: Bool
    var dictionary: [String: Any] {
        return ["id": id, "content": content, "created": created, "senderID": senderID, "senderName": senderName, "showMsg": showMsg, "showMsg1": showMsg1]
    }
    
}

/// Extension to initialize message variables
extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let created = dictionary["created"] as? Int64,
              let senderID = dictionary["senderID"] as? String,
              let senderName = dictionary["senderName"] as? String,
              let showMsg = dictionary["showMsg"] as? Bool,
              let showMsg1 = dictionary["showMsg1"] as? Bool
        else { return nil}
        self.init(id: id, content: content, created: created, senderID: senderID, senderName: senderName, showMsg: showMsg, showMsg1: showMsg1)
    }
    
}

// MARK: - MessageType Implementation

///Declaring Implementing at text based chat for MessageKit 
extension Message: MessageType {
    ///Identify whow the sender of the message is
    var sender: SenderType {
        return Sender(id: senderID, displayName: senderName)
    }
    
    ///Unique id to distinguish a message
    var messageId: String {
        return id
    }
    
    ///Timestap to display messages in order
    var sentDate: Date {
        let ref = Constants.chatRefs.databaseChats.document()
        let timeStamp = Date().timeIntervalSince1970
        let created = Date(timeIntervalSince1970: TimeInterval(TimeInterval(timeStamp)))
        return created //need to fix
    }
    
    ///Declares types of messages being sent are text
    var kind: MessageKind {
        return .text(content)
    }
}

// MARK: - Main Class

class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate {
   
    // MARK: - Class Variables
    
    ///the current user
    var currentUser: User = Auth.auth().currentUser!
    ///firestore reference
    private var docReference: DocumentReference?
    ///Array of message objects to diplay on the screen
    var messages: [Message] = []
    ///Variable of object Profile
    var sendToProfile = Profile()
    /// The username of the current user
    var userID  = Constants.User.sharedInstance.userID
    
    ///Variable information we need for the class
    var senderName: String?
    var user2Name: String?
    var user2UID: String?
    var indexUser: Int?
    
    // MARK: - Set up
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        
        // grabs receiver user information and sets variables to their values from profile
        user2Name = sendToProfile.firstName + " " + sendToProfile.lastName
        user2UID = sendToProfile.uid
        // set title to display receiver name at top of the chat
        self.title = user2Name ?? "Chat"
        //set up the users display name
        setSenderName()
        //set up the header to appear at the top of the screem
        setUpHeader()
        //removes keyboard manager from just this view controller
        IQKeyboardManager.shared.enable = false
        
        /// Sets up the Mesages Collection view for how the content will display
        self.messagesCollectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 70, right: 0)
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .white
        //declares where the sender name will appear above the text bubbles
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: .zero))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .zero))
        //declares where bottom label will display
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .zero))
        //removes avatars from collection view
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAvatarSize(.zero)
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarSize(.zero)
        // Assign MessageViewController to the messages collection, connects delegates
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        loadChat()
    }
    
    ///Creates header with the properties of how it should appear
    func setUpHeader() {
        ///header size
        let viewWidth = self.view.frame.size.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: 75))
        let descLabel = UILabel(frame: CGRect(x: 5, y: 5, width: headerView.frame.size.width , height: headerView.frame.size.height - 10))
        ///header text
        descLabel.text = self.title
        descLabel.textAlignment = .center
        descLabel.font = UIFont(name:"Avenir Next Demi Bold", size: 19.0)
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.65)
        ///subviews to display text over the banner and the banner over the collection view
        headerView.addSubview(descLabel)
        self.view.addSubview(headerView)
    }
    
    ///Loads current user to set the sent the sender name of the outgoing messages
    func setSenderName()
    {
        //get user from users in database
        let userRef = Firestore.firestore().collection("users").whereField("username", isEqualTo: userID)
        userRef.getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                //retrieves user first and last name fields
                let firstname: String? = document.get("firstname") as? String
                let lastname: String? = document.get("lastname") as? String
                let firstnameUnwrapped = firstname ?? "Unknown"
                let lastnameUnwrapped = lastname ?? "Unknown"
                //sets the sender name to the values from firestore
                self.senderName = firstnameUnwrapped + " " + lastnameUnwrapped
            }
        }
        }
    }
    
    ///Creates new relationship and document in Chats to store messages to
    func createNewChat() {
        //fetches data to add
        let users = [self.userID, self.user2UID]
        let data: [String: Any] = ["users":users]
        //creates document in firestore
        let db = Firestore.firestore().collection("Chats")
        db.addDocument(data: data) { (error) in
        if let error = error {
            print("Unable to create chat! \(error)")
            return
        } else {
            self.loadChat()
        }
        }
    }
   
    ///Loads all messages  that exist between current user and second user
    func loadChat() {
    //Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection("Chats").whereField("users", arrayContains: userID )
        
        db.getDocuments { (chatQuerySnap, error) in
        if let error = error {
            print("Error: \(error)")
            return
        } else {
            //Count the no. of documents returned
            guard let queryCount = chatQuerySnap?.documents.count
            else { return }
            if queryCount == 0 {
            //If documents count is zero that means there is no chat available and we need to create a new instance
            self.createNewChat()
            }
            else if queryCount >= 1 {
                //Chat(s) found for currentUser
                for doc in chatQuerySnap!.documents {
                    let chat = Chat(dictionary: doc.data())
                    //Find second user
                    if (chat?.users.contains(self.user2UID ?? "No Second User"))! {
                        self.docReference = doc.reference
                        let showUsers = doc["users"] as? Array ?? [""]
                        self.indexUser = showUsers.firstIndex(of: self.userID)
                        //fetch thread collection
                        doc.reference.collection("thread").order(by: "created", descending:false).addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                            if let error = error {
                                print("Error: \(error)")
                                return
                            } else {
                                // clear array before it is filled
                                self.messages.removeAll()
                                for message in threadQuery!.documents {
                                    //check spot in Chat of the current user
                                    if self.indexUser == 0 {
                                        let view = message.get("showMsg")
                                        //check whether user has deleted message and whether message should show in view
                                        if view as! Bool == true {
                                            let msg = Message(dictionary: message.data())
                                            self.messages.append(msg!)
                                            print("Data: \(msg?.content ?? "No message found")")
                                        }
                                    }
                    else {
                        let view = message.get("showMsg1")
                        if view as! Bool == true {
                            let msg = Message(dictionary: message.data())
                            self.messages.append(msg!)
                            print("Data: \(msg?.content ?? "No message found")")
                        }
                    }
                }
                
                // reload collection view
                self.messagesCollectionView.reloadData()
                // scrolls to last message in the collecton
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
            })
                return
            } //end of if
        } //end of for
        self.createNewChat()
      } else {
        print("Let's hope this error never prints!")
        }
    }
    }
    }
    
    // MARK: - Message Helpers
    
    ///inserts a new message into the feed
    ///
    /// - Parameter message: message being inserted
    private func insertNewMessage(_ message: Message) {
      
      // add message to messages array and reload
      messages.append(message)

      messagesCollectionView.reloadData()
      
        //rescroll the collection view to the bottom
      DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    ///save the message to firestore
    private func save(_ message: Message) {
        //Preparing the data as per our firestore collection
        let data: [String: Any] = ["content": message.content, "created": message.created, "id": message.id, "senderID": message.senderID, "senderName": message.senderName, "showMsg": message.showMsg, "showMsg1": message.showMsg1]
        //Writing it to the thread using the saved document reference we saved in load chat function
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            self.messagesCollectionView.scrollToLastItem()
        })
    }
    
    //MARK: - Input Bar Delegate
    
    ///implement InputBarAccessoryView delegate to call this function when the press send button action occurs
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //variable for message being sent
        let message = Message(id: UUID().uuidString, content: text, created: Int64(Date().timeIntervalSince1970), senderID: userID, senderName: self.senderName ?? "No Sender Name", showMsg: true, showMsg1: true)
    
        //calling function to insert and save message
        insertNewMessage(message)
        save(message)
        //send notification
        sendPush()
        
        //clearing input field
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    
    ///sends push notification to receiver user
    func sendPush() {
        let sender = PushNotificationSender()
        //get receiver user from firestore and check exists
        let uRef = Firestore.firestore().collection("users").document(user2UID ?? "No User")
        uRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                //gets user's token
                let token = document.get("fcmToken") as? String
                //sends push notification to user's token of current message
                sender.sendPushNotification(to: token ?? "No token found", title: self.senderName ?? "New Message", body: "Open to Read Message")
                //reloads table view in MessagingViewController.swiftso if the receiver user does not have the sender as a contact
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
            }
        }
    }
   
    // MARK: - Cell Label functions
    
    ///Checking messages array for setting cell labels attributes
    
    /// - Parameters:
    ///   - indexPath: the current index path of the message in array
    /// - Returns: boolean if the previous message sender is the same as the current
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
            guard indexPath.section - 1 >= 0 else { return false }
            return messages[indexPath.section].senderID == messages[indexPath.section - 1].senderID
        }
    
    ///finds last message sent by the sender
    /// - Parameters:
    ///   - indexPath: the current index path of the message in array
    /// - Returns: boolean if the next message sender is the same as the current
   func isLastBySender(at indexPath: IndexPath) -> Bool {
        let lastSenderMsg :Bool = false
        var countMsg = messages.count-1
        var message = messages[countMsg]
    
        //find last message in messages array sent by the sender
        while(lastSenderMsg == false) {
            if message.senderID == messages[indexPath.item].senderID {
                //check in array bounds
                guard indexPath.section + 1 < messages.count else { return false }
                return messages[indexPath.item].senderID == messages[indexPath.item + 1].senderID
            } else {
                //decrement index path in messages array
                countMsg -= 1
                message = messages[countMsg]
            }
        
        }
    }
    
    // MARK: - Collection View Override
    
    /// Sets that delete action for a collection view selection can be performed
    ///
    /// - Parameters:
    ///   - collectionView: the messages collection view
    ///   - canPerformAction: the long gestue selection
    ///   - forItemAt: index path of selected cell
    ///   - withSender: current user
    /// - Returns: boolean if action can occur
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
            //creates allowable action for delete
            if action == NSSelectorFromString("delete:") {
                return true
            } else {
                return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
            }
    }
    
    /// Performs the action to delete a message at the selected position of the collection view
    ///
    /// - Parameters:
    ///   - collectionView: the messages collection view
    ///   - performAction: selector representing action to be performed
    ///   - forItemAt: index path of selected cell
    ///   - withSender: current user
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        //applies if action selected was delete
        if action == NSSelectorFromString("delete:") {
            /// Remove from datasource
            //creates temporary storage for the message selected and message time created
            let thisMsg = messages[indexPath.section]
            let time = thisMsg.created
            //finds messages in firestore
            let docC = docReference?.collection("thread").whereField("created", isEqualTo: time)
            docC?.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        //checks if message is the correct message
                        if thisMsg.content == document.get("content") as! String {
                           //changes the field to show the message to false depending on which index the username is
                            if self.indexUser == 0 {
                                document.reference.updateData(["showMsg": false])
                            }
                            else {
                                //let document = querySnapshot!.documents.first
                                document.reference.updateData(["showMsg1": false])
                            }
                        }
                    }
                }
            }
            //remove message from messages array
            messages.remove(at: indexPath.section)
            //remove the message section from the messages collection view
            messagesCollectionView.deleteSections([indexPath.section])
            //reload the messages collection view
            messagesCollectionView.reloadData()
        } else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    // MARK: - Override Helpers
    
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    ///reenable KeyboardManager when exit this view controller
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }
}

// MARK: - Extensions

/// Override MessageCollectionViewCell to allow for delete actions
extension MessageCollectionViewCell {

    ///sets action for delete on collection view for a selected cell to appear
    override open func delete(_ sender: Any?) {
        
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                collectionView.delegate?.collectionView?(collectionView, performAction: NSSelectorFromString("delete:"), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}


extension ChatViewController: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> UIColor {
    
    // 1
    return isFromCurrentSender(message: message) ? .blue : .lightGray
  }

  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
  }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    

  func messageStyle(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
}

extension ChatViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return !isPreviousMessageSameSender(at: indexPath) ? 16 : 0
    }
  
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

        return .zero
    }

    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

        return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath,
    with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return 0
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return (!isLastBySender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
        }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(id: userID, displayName: senderName ?? "Name not Found")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func messageTopLabelAttributedText(for message: MessageType,
    at indexPath: IndexPath) -> NSAttributedString? {

        let name = message.sender.displayName
       
        if !isPreviousMessageSameSender(at: indexPath) {
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                       .foregroundColor: UIColor(white: 0.5, alpha: 1)])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        if !isLastBySender(at: indexPath) && isFromCurrentSender(message: message) {
            return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
}
