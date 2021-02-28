//
//  MessagingViewController.swift
//  AccountabilityPods
//
//  Created by SCHOLZ, JENNIFER T on 12/2/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import FirebaseAuth

class MessagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var contactTable: UITableView!
    
    let db = Firestore.firestore()
    var contactsA = [Profile]()
    //var userID = Constants.User.sharedInstance.userID;
    var userID  = Constants.User.sharedInstance.userID;
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadData), name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
        super.viewDidLoad()
        loadData()
        contactTable.delegate = self
        contactTable.dataSource =  self
        
        //view controller to use when presenting modal Chat view controller
        //definesPresentationContext = true
        //setUpElements()
    }
    
    //get users from the database load data
    @objc private func loadData() {
        self.contactsA = []
        let usersRef = db.collection("users").document(userID).collection("CONTACTS");
        
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting users for searching: \(err)")
            }
            else {
                print("Loading Users Contacts")
                for document in querySnapshot!.documents {
                    if document.documentID != "adminuser" && document.documentID != self.userID {
                        let tempProfile = Profile()
                        self.contactsA.append(tempProfile)
                        let path = "users/" + document.documentID
                        tempProfile.readData(database: self.db, path: path, tableview: self.contactTable)
                        //print("document path: \(path)")
                        self.contactTable.reloadData()
                        
                    }
                    
                }
            }
        }
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    //setting size to num of contacts
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("contacts count: \(contactsA.count)")
        return contactsA.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = contactTable.dequeueReusableCell(withIdentifier: "contactName") as! ContactCell
        let contact = contactsA[indexPath.row]
        //print("contact id: \(contact.uid)")
        cell.setContact(profile: contact)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ToChat", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("in prepare override func")
        if segue.identifier == "ToChat" {
            let indexPath = self.contactTable.indexPathForSelectedRow
            let profile = self.contactsA[(indexPath?.row)!]
            //print("selected profile: \(profile.uid)")
            if let dView = segue.destination as? ChatViewController {
                dView.sendToProfile = profile
            }
        }
    }

}
