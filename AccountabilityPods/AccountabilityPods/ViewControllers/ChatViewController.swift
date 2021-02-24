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
    
    //colors for message bubbles
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    let db = Firestore.firestore()
    
    var userID  = Constants.User.sharedInstance.userID;
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        //senderId = "1234"
        //senderDisplayName = "Jhada"
        //set up chat name
        let defaults = UserDefaults.standard

        if  let id = defaults.string(forKey: "jsq_id"),
            let name = defaults.string(forKey: "jsq_name")
        {
            senderId = id
            senderDisplayName = name
        }
        else
        {
            senderId = String(arc4random_uniform(999999))
            senderDisplayName = ""

            defaults.set(senderId, forKey: "jsq_id")
            defaults.synchronize()

            setSenderName()
        }

        self.title = "Chat: \(senderDisplayName!)"
        
        //hide attachment and avatars
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //observing the chat displaying on screen
        let query = Constants.chatRefs.databaseChats.whereField("sender_id", isEqualTo: senderId!)
        query .addSnapshotListener { querySnapshot, error in guard let documents = querySnapshot?.documents else{
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
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    self.messages.append(message)
                    self.finishReceivingMessage()
                }
            }
            //do i need line below?
            //print("\\document.documentID) => \\(document.data())")
        }
            }
        /*query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    if let data = document.data()  as? [String: String],
                    let id = data["sender_id"],
                       let name = data["name"],
                       let text = data["text"],
                       !text.isEmpty {
                        if let message = JSQMessage(senderId: id, displayName: name, text: text)
                        {
                            self.messages.append(message)
                            self.finishReceivingMessage()
                        }
                    }
                    //do i need line below?
                    print("\\document.documentID) => \\(document.data())")
                }
            }
        }*/
    }
    
    //user's display name
    func setSenderName()
    {
        let defaults = UserDefaults.standard
        // get current userID
        let uid = Constants.User.sharedInstance.userID
        let db = Firestore.firestore()
        let userRef = db.collection("users").whereField("uid", isEqualTo: uid)
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
                self.senderDisplayName = name
                self.title = "Chat: \(self.senderDisplayName!)"
                defaults.set(name, forKey: "jsq_name")
                defaults.synchronize()
            }
        }
        }
        
    }
    /*@objc func showDisplayNameDialog()
    {
        let defaults = UserDefaults.standard

        let alert = UIAlertController(title: "Your Display Name", message: "Before you can chat, please choose a display name. Others will see this name when you send chat messages. You can change your display name again by tapping the navigation bar.", preferredStyle: .alert)

        alert.addTextField { textField in

            if let name = defaults.string(forKey: "jsq_name")
            {
                textField.text = name
            }
            else
            {
                let names = ["Ford", "Arthur", "Zaphod", "Trillian", "Slartibartfast", "Humma Kavula", "Deep Thought"]
                textField.text = names[Int(arc4random_uniform(UInt32(names.count)))]
            }
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak alert] _ in

            if let textField = alert?.textFields?[0], !textField.text!.isEmpty {

                self?.senderDisplayName = textField.text

                self?.title = "Chat: \(self!.senderDisplayName!)"

                defaults.set(textField.text, forKey: "jsq_name")
                defaults.synchronize()
            }
        }))

        present(alert, animated: true, completion: nil)
    }*/
    //returns data for message by index
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
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
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }

    //hide JSQ avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    //name labels for message buttons
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = Constants.chatRefs.databaseChats.document()
        
        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]
        
        ref.setData(message as [String : Any])
        
        finishSendingMessage()
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

