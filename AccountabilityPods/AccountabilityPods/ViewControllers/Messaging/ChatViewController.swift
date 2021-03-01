//
//  ChatViewController.swift
//  AccountabilityPods
//
//  Created by KAHAN-THOMAS, JHADA L on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

extension Collection {
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
    
    

}

