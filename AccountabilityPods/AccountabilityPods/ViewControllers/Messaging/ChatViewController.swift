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

struct Chat {
    var users: [String]
    
    var dictionary: [String: Any] {
        return ["users": users]
    }
}
extension Chat {
    init?(dictionary: [String:Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else {
            return nil
        }
        self.init(users: chatUsers)
    }
}

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

extension Message: MessageType {
    var sender: SenderType {
        return Sender(id: senderID, displayName: senderName)
    }
    var messageId: String {
        return id
    }
    var sentDate: Date {
        let ref = Constants.chatRefs.databaseChats.document()
        let timeStamp = Date().timeIntervalSince1970
        let created = Date(timeIntervalSince1970: TimeInterval(TimeInterval(timeStamp)))
        return created //need to fix
    }
    var kind: MessageKind {
        return .text(content)
    }
}
class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate {//, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
   
    var currentUser: User = Auth.auth().currentUser!
    private var docReference: DocumentReference?
    var senderName: String?
    var user2Name: String?
    var user2UID: String?
    var indexUser: Int?
    
    //let db = Firestore.firestore()
    
    private var messages: [Message] = []
    //private var messageListener: ListenerRegistration?
    var sendToProfile = Profile()
    
    var userID  = Constants.User.sharedInstance.userID


    override func viewDidLoad() {
    
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        user2Name = sendToProfile.firstName + " " + sendToProfile.lastName
        user2UID = sendToProfile.uid
        self.title = user2Name ?? "Chat"
        setSenderName()
        
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .white
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: .zero))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .zero))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAvatarSize(.zero)
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarSize(.zero)
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        loadChat()
    }
    //user's display name
    func setSenderName()
    {
        let userRef = Firestore.firestore().collection("users").whereField("username", isEqualTo: userID)
        userRef.getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                let firstname: String? = document.get("firstname") as? String
                let lastname: String? = document.get("lastname") as? String
                let firstnameUnwrapped = firstname ?? "Unknown"
                let lastnameUnwrapped = lastname ?? "Unknown"
                self.senderName = firstnameUnwrapped + " " + lastnameUnwrapped
            }
        }
        }
    }
    func createNewChat() {
        let users = [self.userID, self.user2UID]
        let data: [String: Any] = ["users":users]
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
                let showUsers = doc["user"] as? Array ?? [""]
                self.indexUser = showUsers.firstIndex(of: self.userID)
            //fetch thread collection
            doc.reference.collection("thread").order(by: "created", descending:false).addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                self.messages.removeAll()
                for message in threadQuery!.documents {
                    if self.indexUser == 0 {
                        let view = message.get("showMsg")
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
                    //print("No messages found")
                }
                self.messagesCollectionView.reloadData()
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
    

    private func insertNewMessage(_ message: Message) {
      
      messages.append(message)

      messagesCollectionView.reloadData()
      
      DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    private func save(_ message: Message) {
    //Preparing the data as per our firestore collection
        let data: [String: Any] = ["content": message.content, "created": message.created, "id": message.id, "senderID": message.senderID, "senderName": message.senderName, "showMsg": message.showMsg]
    //Writing it to the thread using the saved document reference we saved in load chat function
    docReference?.collection("thread").addDocument(data: data, completion: { (error) in
    if let error = error {
    print("Error Sending message: \(error)")
    return
    }
        self.messagesCollectionView.scrollToLastItem()
    })
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    //When use press send button this method is called.
        let message = Message(id: UUID().uuidString, content: text, created: Int64(Date().timeIntervalSince1970), senderID: userID, senderName: self.senderName ?? "No Sender Name", showMsg: true, showMsg1: true)
    
        //calling function to insert and save message
        insertNewMessage(message)
        save(message)
        sendPush()
        
        //clearing input field
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    func sendPush() {
        let sender = PushNotificationSender()
        print("this is user2id \(user2UID ?? "no user 2 found for token")")
        let uRef = Firestore.firestore().collection("users").document(user2UID ?? "No User")
        uRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                print("DOCUMENT FOUND \(document.data())")
                let token = document.get("fcmToken") as? String
                print("GOT USER 2 TOKEN \(token ?? "wtoken")")
                sender.sendPushNotification(to: token ?? "No token found", title: self.senderName ?? "New Message", body: "Open to Read Message")
            }
        }
    }
    
    //perfom actions overrides
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
            
            if action == NSSelectorFromString("delete:") {
                return true
            } else {
                return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
            }
        }
        
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

        if action == NSSelectorFromString("delete:") {
            // Remove from datasource
            let thisMsg = messages[indexPath.section]
            let time = thisMsg.created
            print("THIS IS CREATE: \(time)")
            print("MESSAGE CONTENT BEFORE DOC \(thisMsg.content)")
            let docC = docReference?.collection("thread").whereField("created", isEqualTo: time)
            docC?.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("MESSAGE CONTENT \(thisMsg.content)")
                        if thisMsg.content == document.get("content") as! String {
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
            print("MESSAGE TRYING TO DELETE \(messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView))")
            messages.remove(at: indexPath.section)
            print(" AM I HERE \(messages.count)")
            messagesCollectionView.deleteSections([indexPath.section]) //messagesCollectionView
            print(" WHAT Messages after collection remove \(messages.count)")
            messagesCollectionView.reloadData() //messages collection view
            } else {
                super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
                print("WHAT ISTHIS HERE")
            }
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MessageCollectionViewCell {

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
        return 16
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
       
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                       .foregroundColor: UIColor(white: 0.5, alpha: 1)])
    }
}
