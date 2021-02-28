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


class ChatViewController: JSQMessagesViewController
{
    var messages = [JSQMessage]()
    
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
        print("Sending message to: \(sendToProfile.uid)")
        super.viewDidLoad()
        //super.viewDidLoad()
        
        //set up chat name
        //let defaults = UserDefaults.standard

        /*
        if  let id = defaults.string(forKey: "jsq_id"),
            let name = defaults.string(forKey: "jsq_name")
        {
            print("Chat: in this if statement")
            senderId = id
            senderDisplayName = name
            //print("senderId = \(senderId)")
        }
        else
        {
            print("Chat: in this else statement")
            senderId = String(arc4random_uniform(999999))
            senderDisplayName = ""

            defaults.set(senderId, forKey: "jsq_id")
            defaults.synchronize()

            setSenderName()
        }
        */
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
        let chatNav = UINavigationController(rootViewController: ChatViewController())
        self.present(chatNav, animated: true, completion: nil)
    }
    
    //query to database unordered but illegal to add .order(by:  ) with is equal to
    func realtimeUpdate()
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
        //self.messages.removeAll()
        for chatDocument in querySnapshot!.documents {
            let data = chatDocument.data()  as? [String: String]
            let id = data?["sender_id"]
            let rid = data?["receiver_id"]
            let name = data?["name"]
            let text = data!["text"]
            
            if id == self.userID && rid == self.sendToProfile.uid{
                // messages sent by current user and recieved by clicked profile
                if let message = JSQMessage(senderId: id, displayName: name,  text: text)
                {
                    print("Sent message: \(message)")
                    self.messages.append(message)
                    self.finishReceivingMessage()
                }
            } else if id == self.sendToProfile.uid && rid == self.userID {
                // messages sent by clicked profile and recieved by current user
                if let message = JSQMessage(senderId: id, displayName: self.receiverName, text: text)
                {
                    print("Recieved message: \(message)")
                    self.messages.append(message)
                    self.finishReceivingMessage()
                }
            }
            
        }
        }
    }

    //returns data for message by index
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        print("JSQ message: \(messages[indexPath.item])")
        return messages[indexPath.item]
    }
    
    //total num of messages
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    //bubble image color associated with message sending
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let message = messages[indexPath.row]
        
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
        return messages[indexPath.item].senderId == self.senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == self.senderId ? 0 : 15
    }
    
    //creating the message and finish sening kind of reloads the page
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = Constants.chatRefs.databaseChats.document()
        
        let timeStamp = Firebase.Timestamp().dateValue()
        //print("timestampHERE: \(timeStamp)")
        
        let message = ["sender_id": senderId!, "receiver_id": sendToProfile.uid, "name": senderDisplayName!, "text": text!, "date":"\(timeStamp)"]
        
        print("MESSAGEWITHDATE: \(message["date"])")
        ref.setData( message as [String : Any])
        
        finishSendingMessage()
    }
    
    //beginning of delete message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        //let message = messages[indexPath.item]
        let message = messages[indexPath.item]
        //Constants.chatRefs.databaseChats.whereField("sender_id", isEqualTo: message.senderId!).document(where("text", isEqualTo: message.text!))
        
        messages.remove(at: indexPath.item)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    

}

