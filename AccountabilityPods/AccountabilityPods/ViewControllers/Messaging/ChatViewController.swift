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
    var dictionary: [String: Any] {
        return ["id": id, "content": content, "created": created, "senderID": senderID, "senderName": senderName, "showMsg": showMsg]
    }
    
}

extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let created = dictionary["created"] as? Int64,
              let senderID = dictionary["senderID"] as? String,
              let senderName = dictionary["senderName"] as? String,
              let showMsg = dictionary["showMsg"] as? Bool
        else { return nil}
        self.init(id: id, content: content, created: created, senderID: senderID, senderName: senderName, showMsg: showMsg)
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
    
    //let db = Firestore.firestore()
    
    private var messages: [Message] = []
    //private var messageListener: ListenerRegistration?
    var sendToProfile = Profile()
    
    var userID  = Constants.User.sharedInstance.userID;


    override func viewDidLoad() {
    
        super.viewDidLoad()
        
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
       // let defaults = UserDefaults.standard
        // get current userID
        //let uid = Constants.User.sharedInstance.userID
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
            //fetch thread collection
            doc.reference.collection("thread").order(by: "created", descending:false).addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                self.messages.removeAll()
                for message in threadQuery!.documents {
                    let view = message.get("showMsg")
                    if view as! Bool == true {
                        let msg = Message(dictionary: message.data())
                        self.messages.append(msg!)
                        print("Data: \(msg?.content ?? "No message found")")
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
        let message = Message(id: UUID().uuidString, content: text, created: Int64(Date().timeIntervalSince1970), senderID: userID, senderName: self.senderName ?? "No Sender Name", showMsg: true)
    //calling function to insert and save message
    insertNewMessage(message)
    save(message)
    //clearing input field
    inputBar.inputTextView.text = ""
    messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    func sendPush() {
        let sender = PushNotificationSender()
        let uRef = Firestore.firestore().collection("users").document(user2UID ?? "No User")
        _ = uRef.addSnapshotListener() {
            document, err in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else
            {
                let token = document!.get("fcmToken") as! String
                sender.sendPushNotification(to: token, title: self.senderName ?? "New Message", body: "Open to Read Message")
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
                // 1.) Remove from datasource
                let time = messages[indexPath.row + 1].created
                print(" THIS IS THE MESSAGE\(messages[indexPath.row + 1].content)")
                print("THIS IS CREATE: \(time)")
                //let show = false
                let docC = docReference?.collection("thread").whereField("created", isEqualTo: time)
                docC?.getDocuments() { (querySnapshot, err) in
                if let err = err {
                print("Error getting documents: \(err)")
                } else {
                let document = querySnapshot!.documents.first
                document?.reference.updateData(["showMsg": false])
                }
                }
            
                messages.remove(at: indexPath.section)
                print(" AM I HERE \(messages.count)")
                messagesCollectionView.deleteSections([indexPath.section])
                print(" WHAT Messages after collection remove \(messages.count)")
                messagesCollectionView.reloadData()
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

    // 3
    return .bubbleTail(corner, .curved)
  }
}

extension ChatViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
  
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    // 1
    return .zero
  }

  func footerViewSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    // 2
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
    /*@objc func delete(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: self.messagesCollectionView)
            if let indexPath = messagesCollectionView.indexPathForItem(at: touchPoint){
                messages.remove(at: indexPath.section)
                print(" AM I HERE \(messages.count)")
                messagesCollectionView.deleteSections([indexPath.section])
                print(" WHAT Messages after collection remove \(messages.count)")
                messagesCollectionView.reloadData()
                }
        }
    }*/
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        print("GETTING NUM OF SECTIONS: \(messages.count)")
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




/*extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
class chatMsg {
    public var msg: JSQMessage
    public var msgTime: Int64
    init()
    {
        self.msg = JSQMessage(senderId: "jsq_id", displayName: "jsq_name",  text: "jsq_test")
        self.msgTime = 0
    }
    init(msg: JSQMessage, msgTime: String)
    {
        let timeInt = Int64(msgTime)
        self.msg = msg
        if(timeInt == nil)
        {
            self.msgTime = 0
        }
        else {
            self.msgTime = timeInt ?? 0
        }
    }
}

class ChatViewController: JSQMessagesViewController
{
    var messages = [JSQMessage]()
    var orderedMsgs = [chatMsg]()
    var sendToProfile = Profile()
    var receiverName = ""
    
    //colors for message bubbles
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    let db = Firestore.firestore()
    
    var userID  = Constants.User.sharedInstance.userID;
    
    //load view controller
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.realtimeUpdate), name: NSNotification.Name(rawValue: "OutgoingMessagesDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.realtimeUpdate), name: NSNotification.Name(rawValue: "IncomingMessagesDeleted"), object: nil)
        print("Sending message to: \(sendToProfile.uid)")
        super.viewDidLoad()
        //super.viewDidLoad()
        
        //set up chat name
        
        senderDisplayName = ""
        senderId = userID as! String
        setSenderName()
        receiverName = sendToProfile.firstName + " " + sendToProfile.lastName
        
        self.title = "Chat: \\(senderDisplayName!)"
        
        //hide attachment and avatars
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //observing the chat displaying on screen
        self.realtimeUpdate()
        //messages.append(JSQMessage(senderId: "id", displayName: "tim",  text: "testing"))
        collectionView.reloadData()
    }
    
    //user's display name
    func setSenderName()
    {
        let defaults = UserDefaults.standard
        // get current userID
        let uid = Constants.User.sharedInstance.userID
        //let db = Firestore.firestore()
        let userRef = db.collection("users").whereField("username", isEqualTo: uid)
        userRef.getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                let firstname: String? = document.get("firstname") as? String
                let lastname: String? = document.get("lastname") as? String
                let firstnameUnwrapped = firstname ?? "Unknown"
                let lastnameUnwrapped = lastname ?? "Unknown"
                let name = firstnameUnwrapped + " " + lastnameUnwrapped
                self.senderId = document.get("username") as? String
                self.senderDisplayName = name
                self.parent?.title = "Chat: \(self.senderDisplayName!)"
                defaults.set(self.userID, forKey: "jsq_id")
                defaults.set(name, forKey: "jsq_name")
                defaults.synchronize()
            }
        }
        }
        //trying to get nav bar at the top with title and line below
        //let chatNav = UINavigationController(rootViewController: ChatViewController())
        //self.present(chatNav, animated: true, completion: nil)
    }
    
    //query to database unordered but illegal to add .order(by:  ) with is equal to
    @objc func realtimeUpdate()
    {
        /*
        let query = Constants.chatRefs.databaseChats.whereField("sender_id", isEqualTo: self.senderId!)
        query.addSnapshotListener { querySnapshot, error in guard (querySnapshot?.documents) != nil else{
            print("Error getting documents: \(error!)")
            return
        }
        self.messages.removeAll()
        for document in querySnapshot!.documents {
            if let data = document.data()  as? [String: String],
            let id = data["sender_id"],
               let name = data["name"],
               let text = data["text"],
               !text.isEmpty {
                if let message = JSQMessage(senderId: id, displayName: name,  text: text)
                {
                    self.messages.append(message)
                    self.finishReceivingMessage()
                }
                
            }
        }
        }*/
        let userIDs = [userID, sendToProfile.uid]
        // get documents where the sender_id is either userID or the user id of the clicked contact - this gets all messages sent by both users to any user
        let query = Constants.chatRefs.databaseChats.whereField("sender_id", in: userIDs)
        query.addSnapshotListener { querySnapshot, error in guard (querySnapshot?.documents) != nil else {
            print("error getting documents: \(error)")
            return
        }
        self.orderedMsgs.removeAll()
        print("Count \(self.orderedMsgs.count)")
       
        for chatDocument in querySnapshot!.documents {
            let data = chatDocument.data()  as? [String: String]
            let id = data?["sender_id"]
            let rid = data?["receiver_id"]
            let name = data?["name"]
            let text = data!["text"]
            let time = data?["date"]
            
            if id == self.userID && rid == self.sendToProfile.uid{
                // messages sent by current user and recieved by clicked profile
                if let message = JSQMessage(senderId: id, displayName: name,  text: text)
                {
                    let newMsg = chatMsg(msg: message, msgTime: time ?? "0")
                    print("Sent message: \(message)")
                    self.messages.append(message)
                    self.orderedMsgs.append(newMsg)
                    self.finishReceivingMessage()
                }
            } else if id == self.sendToProfile.uid && rid == self.userID {
                // messages sent by clicked profile and recieved by current user
                if let message = JSQMessage(senderId: id, displayName: self.receiverName, text: text)
                {
                    let newMsg = chatMsg(msg: message, msgTime: time ?? "0")
                    print("Recieved message: \(message)")
                    self.messages.append(message)
                    self.orderedMsgs.append(newMsg)
                    self.finishReceivingMessage()
                }
            }
        }
        print("Sorting Messages")
        self.sortMsgs()
        }
    }
    
    func sortMsgs()
    {
        var count = 0
        while count < orderedMsgs.count {
            var count2 = 0
            while count2 < orderedMsgs.count
            {
                print("Checking if msg at \(count) > \(count2)")
                if orderedMsgs[count].msgTime < orderedMsgs[count2].msgTime
                {
                    print("swapping")
                    let tempMsg = orderedMsgs[count]
                    orderedMsgs[count] = orderedMsgs[count2]
                    orderedMsgs[count2] = tempMsg
                }
              count2 += 1
            }
            count += 1
        }
    }
    //returns data for message by index
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        if indexPath.item >= orderedMsgs.count {
            return JSQMessage(senderId: "", displayName: "", text: "")
        }
        print("JSQ message: \(orderedMsgs[indexPath.item].msg)")
        return orderedMsgs[indexPath.item].msg
    }
    
    //total num of messages
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //sortMsgs() didnt sort
        return orderedMsgs.count
    }
    
    //bubble image color associated with message sending
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        if indexPath.item >= orderedMsgs.count {
            return self.incomingBubble
        }
        let message = orderedMsgs[indexPath.row].msg
        
        if self.senderId == message.senderId {
            return self.outgoingBubble
        }
        
        return self.incomingBubble
        //return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }

    //hide JSQ avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    //name labels for message buttons
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        if indexPath.item >= orderedMsgs.count {
            return NSAttributedString(string: "")
        }
        return orderedMsgs[indexPath.item].msg.senderId == self.senderId ? nil : NSAttributedString(string: orderedMsgs[indexPath.item].msg.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        if indexPath.item >= orderedMsgs.count {
            return 0
        }
        return orderedMsgs[indexPath.item].msg.senderId == self.senderId ? 0 : 15
    }
    
    //creating the message and finish sening kind of reloads the page
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = Constants.chatRefs.databaseChats.document()
        
        let timeStamp = Firebase.Timestamp().seconds //.D
        //print("timestampHERE: \(timeStamp)")
        
        let message = ["sender_id": senderId!, "receiver_id": sendToProfile.uid, "name": senderDisplayName!, "text": text!, "date":"\(timeStamp)"]
        
        print("MESSAGEWITHDATE: \(message["date"])")
        ref.setData( message as [String : Any])
        sortMsgs()
        finishSendingMessage()
    }
    
    //beginning of delete message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        if indexPath.item >= orderedMsgs.count {
            return
        }
        //let message = messages[indexPath.item]
        let message = orderedMsgs[indexPath.item].msg
        //Constants.chatRefs.databaseChats.whereField("sender_id", isEqualTo: message.senderId!).document(where("text", isEqualTo: message.text!))
        
        messages.remove(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: IndexPath!)   {
        if indexPath.item >= orderedMsgs.count {
            return
        }
       // Do the custom JSQM stuff
        super.collectionView(collectionView, didTapMessageBubbleAt: indexPath)
        let message = orderedMsgs[indexPath.item].msg
       print("Did Select this method!")
      // And return true for all message types (we don't want the long press menu disabled for any message types)
    }

    /*override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
      super.collectionView(collectionView, performAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }*/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    

}*/
