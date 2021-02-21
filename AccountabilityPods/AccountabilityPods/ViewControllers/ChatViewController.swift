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
    
    @IBOutlet weak var userMsg: UITextField!
    let db = Firestore.firestore()
    
    var userID  = Constants.User.sharedInstance.userID;
    
    @IBOutlet weak var msgContain: UIView!
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        senderId = "1234"
        senderDisplayName = "Jhada"
        
        //hide attachment and avatars
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //observing the chat displaying on screen
        let query = Constants.chatRefs.databaseChats.whereField("sender_id", isEqualTo: senderId)
        query.getDocuments() { (querySnapshot, err) in
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
        }
    }
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
        
        ref.setData(message)
        
        finishSendingMessage()
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func txtDone(_ sender: Any) {
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewMsg"), object: nil)
        var ref = db.collection("users").document(userID).collection("MSG").addDocument(data: ["senderId" : userID, "message" : userMsg.text ?? "" ])
        {err in
        if let err = err {
            print("The document was invalid for some reason? \(err)")
        }
            else{
                print("Document added successfully.")
                self.dismiss(animated:true, completion:nil)
            }
        }
        userMsg.text = "Type Here..."
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

