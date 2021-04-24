//
//  MessagingViewController.swift
//  AccountabilityPods
//
//  Created by SCHOLZ, JENNIFER T on 12/2/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages the pages that shows user to message
import UIKit
import Foundation
import Firebase
import FirebaseAuth

class MessagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI Connectors
    
    /// The table with user profiles to message
    @IBOutlet var contactTable: UITableView!
    
    // MARK - Class Variables
    
    /// The firestore database
    let db = Firestore.firestore()
    /// Array of profile objects (class in Utilities.swift) to show in the table
    var contactsA = [Profile]()
    /// The username of the current user
    var userID  = Constants.User.sharedInstance.userID;
    
    override func viewDidLoad() {
        // calls view did load when a contact is added or removed
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadData), name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // loads data into the array of profiles
        loadData()
        // Assign UITableViewDelegate to the contacts table
        contactTable.delegate = self
        contactTable.dataSource =  self
    }
    
    // MARK: - Set up
    
    /// Load contacts and users who have messaged current user into array of profiles.
    @objc private func loadData() {
        // clear array before it is filled
        self.contactsA.removeAll()
        // get users from contacts 
        let usersRef = db.collection("users").document(userID).collection("CONTACTS");
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting users: \(err)")
            } else {
                print("Reading users from contacts")
                for document in querySnapshot!.documents {
                    if document.documentID != "adminuser" && document.documentID != self.userID {
                        // check if user exists
                        let userRef = self.db.collection("users").document(document.documentID)
                        userRef.getDocument { (userdocument, err) in
                            if let userdocument = userdocument, userdocument.exists {
                                // user exists in database
                                let tempProfile = Profile()
                                // add profile to array
                                self.contactsA.append(tempProfile)
                                let path = "users/" + document.documentID
                                 tempProfile.readData(database: self.db, path: path, tableview: self.contactTable)
                                print("msgContact added: \(document.documentID)")
                                print("msgContact array size: \(self.contactsA.count)")
                                // reload table with new contact
                                self.contactTable.reloadData()
                            } else {
                                print("user \(document.documentID) does not exist")
                            }
                        }
                                         
                    }
                    
                }
            }
        }
        // get users from chats, should add users that are not in contacts.
        db.collection("Chats").whereField("users" , arrayContains: self.userID)
        .getDocuments{(querySnapshot, err) in
            if let err = err {
                print("Error getting users for searching: \(err)")
            }
            else {
                print("Loading Users Messages")
                for document in querySnapshot!.documents {
                    let chatUsers = document["users"] as? Array ?? [""]
                    // get both users listed in chat and choose the one that is not current user
                    for user in chatUsers{
                        if user != self.userID && user.count > 0{
                            // check if user exists
                            let userRef = self.db.collection("users").document(user)
                            userRef.getDocument { (document, err) in
                                if let document = document, document.exists {
                                    // user exists
                                    // Check if user var is in contacts
                                    let contactRef = self.db.collection("users").document(self.userID).collection("CONTACTS").document(user)
                                    contactRef.getDocument { (document, err) in
                                        if let document = document, document.exists{
                                            print("\(user) is already contact")
                                        } else {
                                            print("\(user) sent message but is not a contact")
                                            // add user to array of contacts
                                            let path = "users/" + user
                                            let tempProfile = Profile()
                                            self.contactsA.append(tempProfile)
                                            tempProfile.readData(database: self.db, path: path, tableview: self.contactTable)
                                            self.contactTable.reloadData()
                                            
                                        }
                                    }                                
                                } else {
                                    print("User \(user) does not exist")
                                }
                            }
                            
                            
                        }
                    }
                    
                }
            }
        }
    }
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - Table functions
    
    /// Sets the number of rows in table determined by number of profiles in array.
    /// 
    /// - Parameters:
    ///   - tableView: the contacts table
    ///   - numberOfRowsInSection: the numnber of rows in the table
    /// - Returns: the number of rows in the profile array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("contacts count: \(contactsA.count)")
        return contactsA.count
    }
    
    /// Creates the cell in the table with the info from the profile in the profile array.
    /// 
    /// - Parameters:
    ///   - tableView: the contacts table
    ///   - cellForRowAt indexPath: the index of the row in the table that need information
    /// - Returns: the cell to be inputted into the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell using Helpers/ContactCell.swift class
        let cell = contactTable.dequeueReusableCell(withIdentifier: "contactName") as! ContactCell
        // get cell with given index
        let contact = contactsA[indexPath.row]
        // set the cell to have the information from the profile object
        cell.setContact(profile: contact)
        return cell
    }
    
    /// Transitions to chat for tap profile in table.
    /// 
    /// - Parameters:
    ///   - tableView: the contact table
    ///   - didSelectRowAt indexPath: the index of the tapped row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // transitions to the chat room for the selected profile
        if let presented = self.presentedViewController {
            presented.removeFromParent()
        }
        self.performSegue(withIdentifier: "ToChat", sender: Any?.self)
    }
    
    /// Prepares transition to chat and transfer profile object to chat view controller.
    ///
    /// - Parameters:
    ///   - segue: the segue on the storyboard that connects the messaging page to the chat room
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // sends tapped profile through segue to chat viewcontroller
        if segue.identifier == "ToChat" {
            let indexPath = self.contactTable.indexPathForSelectedRow
            let profile = self.contactsA[(indexPath?.row)!]
            if let dView = segue.destination as? ChatViewController {
                dView.sendToProfile = profile
            }
        }
    }
    
    /// Deletes all messages from a user when cell is swiped to delete.
    /// 
    /// - Parameters: 
    ///   - tableView: the contact table
    ///   - editingStyle: the style for the swiped cell
    ///   - indexPath: the index of the swiped cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //delete your messages sent to a user
        if editingStyle == .delete {
            //pull docs from both users
            let userIDs = [userID, contactsA[indexPath.item].uid]
                
            let query = Constants.chatRefs.databaseChats.whereField("sender_id", in: userIDs)
            query.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("error getting documents: \(err)")
                } else {
                    print("\(querySnapshot!.documents)")
                    for document in querySnapshot!.documents {
                    let data = document.data()  as? [String: String]
                    let id = data?["sender_id"]
                    let rid = data?["receiver_id"]
                    if id == self.userID && rid == self.contactsA[indexPath.item].uid {
                        self.db.document(document.reference.path).delete() { err in if let err = err {
                            print("Error ermoving document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OutgoingMessagesDeleted"), object: nil)
                            }
                        }
                        }
                    else if id == self.contactsA[indexPath.item].uid && rid == self.userID {
                        self.db.document(document.reference.path).delete() { err in if let err = err {
                            print("Error ermoving document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IncomingMessagesDeleted"), object: nil)
                            }
                        }
                    }
                    }
                }
            }
        }
                else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
            }
        }
    
    // MARK: - Pop Ups
    
    /// Shows a pop up that explains how to use the messaging page.
    ///
    /// - Parameter sender: the tapped object
    @IBAction func helpTapped(_ sender: Any) {
        // prepares and presents the pop up
        let alertController = UIAlertController(title: "Messages Help", message: "Tap on user to view, send, and delete messages\nTo send message to a new user add them to your pod and they will appear", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)    }
    
}
