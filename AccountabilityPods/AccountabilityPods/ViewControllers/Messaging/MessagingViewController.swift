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
    /// Whether refreshing is complete
    var finishedRefreshing = true;
    /// The refreshing feature
    let refresh = UIRefreshControl()
    
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
        // set up refreshing functionality
        contactTable.refreshControl = refresh;
        refresh.addTarget(self, action: #selector(self.reload(_:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "Fetching new messages")
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
                            userRef.getDocument { (existsdocument, err) in
                                if let existsdocument = existsdocument, existsdocument.exists {
                                    // user exists
                                    // Check if user var is in contacts
                                    let contactRef = self.db.collection("users").document(self.userID).collection("CONTACTS").document(user)
                                    contactRef.getDocument { (userdocument, err) in
                                        if let userdocument = userdocument, userdocument.exists{
                                            print("\(user) is already contact")
                                        } else {
                                            print("\(user) sent message but is not a contact")
                                            // check if user has deleted messages
                                            let userIndex = chatUsers.firstIndex(of: self.userID)
                                            var showMsgFieldName = "showMsg"
                                            if userIndex == 1 {
                                                showMsgFieldName = "showMsg1"
                                            }
                                            //print("USER INDEX: \(userIndex ?? 2), field: \(showMsgFieldName)")
                                            let threadPath = document.reference.path + "/thread"
                                            // get all documents for thread
                                            self.db.collection(threadPath).getDocuments { (messages, err) in
                                                if let err = err {
                                                    print("Error getting messages: \(err)")
                                                } else {
                                                    for message in messages!.documents {
                                                        // if user is able to see a single document
                                                        
                                                        if message[showMsgFieldName] as? Int ?? 0 == 1 {
                                                            print("not contact user has available message")
                                                            let path = "users/" + user
                                                            let tempProfile = Profile()
                                                            self.contactsA.append(tempProfile)
                                                            tempProfile.readData(database: self.db, path: path, tableview: self.contactTable)
                                                            self.contactTable.reloadData()
                                                            return
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            
                                        }
                                    }                                
                                } else {
                                    print("User \(user) does not exist")
                                }
                            }
                            
                            
                        }
                    }
                    
                }
                self.finishedRefreshing = true
            }
        }
    }
    /// Reloads the data when table is pulled down to refresh
    @objc func reload(_ sender: Any) {
        if(finishedRefreshing)
        {
            finishedRefreshing = false;
            self.loadData();
        }
        refresh.endRefreshing();
    }
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /// Returns number of sections for the table.
    ///
    /// - Parameter tableView: the contacts table
    /// - Returns: the number of contacts in the array
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.contactsA.count
    }
    // MARK: - Table functions
    
    /// Sets the number of rows in table determined by number of profiles in array.
    /// 
    /// - Parameters:
    ///   - tableView: the contacts table
    ///   - numberOfRowsInSection: the numnber of rows in the table
    /// - Returns: 1
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("contacts count: \(contactsA.count)")
        return 1
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
        if indexPath.section < contactsA.count {
            let contact = contactsA[indexPath.section]
            // set the cell to have the information from the profile object
            cell.setContact(profile: contact)
        }
        
        return cell
    }
    
    /// Sets the height of the space between  cells
    ///
    /// - Parameter:
    ///   - tableView: the contact table
    ///   - heightForHeaderInSection: the height of the space between cells
    /// - Returns: the height (20) for the space between cells
    func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        return 10
    }
    
    /// Sets the height of the space between  cells
    ///
    /// - Parameter:
    ///   - tableView: the contact table
    ///   - heightForHeaderInSection: the height of the space between cells
    /// - Returns: the height (20) for the space between cells
    func  tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == contactsA.count - 1 {
            return 20
        }
        return 10
    }
    
    /// Shows and makes cosmetic changes to space between cells
    ///
    /// - Parameter:
    ///   - tableView: the contact table
    ///   - viewForHeaderInSection section: the index of the cell
    /// - Returns: the headerView with cosmetic changes
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        // changes background color of the header to be a clear space between cells
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    /// Shows and makes cosmetic changes to space between cells
    ///
    /// - Parameter:
    ///   - tableView: the contact table
    ///   - viewForHeaderInSection section: the index of the cell
    /// - Returns: the headerView with cosmetic changes
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        // changes background color of the header to be a clear space between cells
        headerView.backgroundColor = UIColor.clear
        return headerView
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
            let profile = self.contactsA[(indexPath?.section)!]
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
            
            //alert to confirm delete
            let alertController = UIAlertController(title: "Delete Chat", message: "Would you like to clear your chat? If you're not contacts this user will be removed from messages completely.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                    do {
                        self.dismiss(animated:true, completion: {
                                //reference Chat relationship for current user
                                let query = Constants.chatRefs.databaseChats.whereField("users", arrayContains: self.userID)
                                query.getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print("error getting documents: \(err)")
                                    } else {
                                        for doc in querySnapshot!.documents {
                                            
                                            let chat = Chat(dictionary: doc.data())
                                            //find if this is the document for selected user
                                            if(chat?.users.contains(self.contactsA[indexPath.section].uid ))! {
                                                print("6574: \(doc.reference.path)")
                                                let usersArray = doc["users"] as? Array ?? [""]
                                                //which index the current user is in the documnet
                                                let userIndex = usersArray.firstIndex(of: self.userID)
                                                ///go through the thread of messages to change show message
                                                doc.reference.collection("thread").getDocuments() { (querySnapshot, err) in
                                                    if let err = err {
                                                        print("Error getting documents: \(err)")
                                                    }
                                                    else {
                                                        
                                                        for document in querySnapshot!.documents {
                                                            if userIndex == 0 {
                                                                print("6575: \(document.reference.path)")
                                                                document.reference.updateData(["showMsg": false])
                                                                
                                                            }
                                                            else {
                                                                print("6576: \(document.reference.path)")
                                                                document.reference.updateData(["showMsg1": false])
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            ///Remove the user from the table if they are not the current users contact
                                let usersRef = self.db.collection("users").document(self.userID).collection("CONTACTS")
                            usersRef.getDocuments() {(querySnapshot, err) in
                                if let err = err {
                                    print("DOCUMENTs DOES EXIST \(err)")
                                } else {
                                    //check if document of other user is in the contacts
                                    let isContact = self.db.collection("users").document(self.userID).collection("CONTACTS").document(self.contactsA[indexPath.section].uid)
                                    isContact.getDocument { (document, err) in
                                        if let document = document, document.exists{
                                            print("\(self.contactsA[indexPath.section].uid) is already contact")
                                        } else {
                                            //remove from the table view
                                            self.contactsA.remove(at: indexPath.section)
                                            tableView.deleteRows(at: [indexPath], with: .fade)
                                            print("REMOVED from table view")
                                        }
                                    }
                                }
                            }
                    })
                    }
                }))
            alertController.addAction(UIAlertAction(title:"No", style: .default, handler: nil))
            self.present(alertController, animated: true)
            
        }

        }
   
    
    // MARK: - Pop Ups
    
    /// Shows a pop up that explains how to use the messaging page.
    ///
    /// - Parameter sender: the tapped object
    @IBAction func helpTapped(_ sender: Any) {
        // prepares and presents the pop up
        let alertController = UIAlertController(title: "Messages Help", message: "Tap on user to view, send, and delete messages\nTo send message to a new user add them to your pod and they will appear \nPull down page to refresh messages", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)
        
    }
    
}
