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
    var data = [String]()
    var contactsA = [Profile]()
    var filteredData = [String]()
    var filteredContacts = [Profile]()
    var filtered = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        contactTable.delegate = self
        contactTable.dataSource =  self
        // Do any additional setup after loading the view.
        //setUpElements()
    }
    
    //get users from the database load data
    private func loadData() {
        let usersRef = db.collection("users")
        
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting users for searching: \(err)")
            }
            else {
                print("Loading Users for Search Display")
                for document in querySnapshot!.documents {
                    if document.documentID != "adminuser" {
                        let tempProfile = Profile()
                        self.contactsA.append(tempProfile)
                        tempProfile.readData(database: self.db, path: document.reference.path, tableview: self.contactTable)                    }
                    
                }
            }
        }
    }
    
    func filterText(_ query: String) {
        print("QUERY: \(query)")
        filteredContacts.removeAll()
        for profile in contactsA {
            let userString = profile.uid
            let firstString = profile.firstName
            let lastString = profile.lastName
            if (userString.lowercased().starts(with: query.lowercased()) || firstString.lowercased().starts(with: query.lowercased()) || lastString.lowercased().starts(with: query.lowercased()))
            {
                filteredContacts.append(profile)
                contactTable.reloadData()
            }
        }
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filtered = false
            filteredContacts.removeAll()
        } else {
            filtered = true
        }
        print("FILTERED: \(filtered)")
        contactTable.reloadData()
        
    }
    
    /*func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }*/
    
    //setting size to num of users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredContacts.isEmpty {
            return filteredContacts.count
        }
        return filtered ? 0 : contactsA.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("filling cells")
        let cell = contactTable.dequeueReusableCell(withIdentifier: "contactName") as! ContactCell
        if !filteredContacts.isEmpty {
            print("showing filtered profiles")
            let contact = filteredContacts[indexPath.row]
            cell.setContact(profile: contact)
        } else {
            print("showing all profiles")
            let contact = contactsA[indexPath.row]
            cell.setContact(profile: contact)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ToChat", sender: Any?.self)
    }
    
    //for retrieving names for contacts from firestore
    /*func loadData() {
        db.collection("users").document(Constants.User.sharedInstance.userID).collection("CONTACTS").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents{
                    let data = document.data()
                    let con = data["userRef"] as? String ?? ""
                    self.contactsA.append(con)
                    }
                }
            }
        }
        
    }*/
    /*func setUpElements() {
        errorLabel.alpha = 0 // hide error label
    }*/

}
