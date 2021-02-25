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
    
    var db:Firestore!
    var contactsA = [String]()
    //@IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var contactTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadData()
       contactsA = ["adminUser"]
        contactTable.delegate = self
        contactTable.dataSource =  self
        // Do any additional setup after loading the view.
        //setUpElements()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("TableView setup \(contactsA.count)")
        return contactsA.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactName", for: indexPath)
        //let contact = contactsA[indexPath.row]
        cell.textLabel?.text = contactsA[indexPath.row]
        //cell.contactName.text = contact
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        self.performSegue(withIdentifier: "ToChat", sender: Any?.self)    }
    
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
