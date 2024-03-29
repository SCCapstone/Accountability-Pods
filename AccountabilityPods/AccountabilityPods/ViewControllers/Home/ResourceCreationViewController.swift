//
//  resourceCreationViewController.swift
//  AccountabilityPods
//
//  Created by Duncan Evans on 11/27/20. {Ported from other branch 11/25/20}
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages the "Share a Resource" page

import UIKit
import Firebase
class ResourceCreationViewController: UIViewController {
    
    // MARK: - Class Variables
    /// The firestore database
    let db = Firestore.firestore()
    /// This userID is acquired from the login event, and is the user's userID which is autogenerated by Firestore
    var userID = Constants.User.sharedInstance.userID;
    /// the user added description
    @IBOutlet weak var resourceDesc: UITextView!
    /// the user added resource name
    @IBOutlet weak var resourceName: UITextField!
    /// the user added image link
    @IBOutlet weak var imageLink: UITextField!
    /// the user added deletion date (Organizations only)
    @IBOutlet weak var deletionDate: UIDatePicker!
    /// label for Deletion Date
    @IBOutlet weak var delDateLabel: UILabel!
    //the user added description (non org)
    @IBOutlet weak var nonOrgResDesc: UITextView!
    
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the page to only work in light mode
        overrideUserInterfaceStyle = .light
        // cosmetically changes text boxes
        resourceName.layer.cornerRadius = 5
        resourceDesc.layer.cornerRadius = 5
        
        let usersRef = db.collection("users")
        var fake = 2
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            }
            else {
        for document in querySnapshot!.documents {
            if document.documentID != "adminuser" && document.documentID == self.userID {
                if document.get("organization") as? Int == 1 && document.get("username") != nil{
                    fake = 1
                }
                else {
                    fake = 0
                }
            }
        
        }
    }
        if(fake == 1) {
            self.imageLink.isHidden = false
            self.deletionDate.isHidden = false
            self.delDateLabel.isHidden = false
            self.nonOrgResDesc.isHidden = true
        } else {
            self.imageLink.isHidden = true
            self.deletionDate.isHidden = true
            self.delDateLabel.isHidden = true
            self.nonOrgResDesc.isHidden = false
        }
    }
    }
        
    
    /// Hides the keyboard when other part of screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Button functionality
    
    /// Adds new post  database
    ///
    /// - Parameter sender: the add post button
    @IBAction func onAddPressed(_ sender: Any) {
        // check if resource has enough information
        if resourceName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || resourceDesc.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" && nonOrgResDesc.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            // resource information has not been entered
            let alertController = UIAlertController(title: "Need more info", message: "Resource name or description is missing. Please add this information", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
            self.present(alertController, animated: true)
        }   else {
            // create resource in database for Org
            let timeStamp = Firebase.Timestamp().seconds
            let delD = self.deletionDate?.date.timeIntervalSince1970
            if(nonOrgResDesc.isHidden == false) {
                resourceDesc.text = nonOrgResDesc.text
            }
            _ =
                db.collection("users").document(userID).collection("POSTEDRESOURCES").addDocument(data: [
                        "creatorRef" : userID,
                "imageLink" : imageLink.text ?? "N/A",
                        "resourceDesc" : resourceDesc.text ?? "N/A",
                "resourceName" : resourceName.text ?? "N/A", "time": timeStamp, "deletionDate" : delD ?? 0
                    ]) {err in
                        if let err = err {
                            print("The document was invalid for some reason? \(err)")
                        }
                        else{
                            print("Document added successfully.")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditResource"), object: nil)
                            self.dismiss(animated:true, completion:nil)
                        }

                        }
            if(nonOrgResDesc.isHidden) {
                db.collection("organizations").document(userID).collection("POSTEDRESOURCES").addDocument(data: [
                        "creatorRef" : userID,
                "imageLink" : imageLink.text ?? "N/A",
                        "resourceDesc" : resourceDesc.text ?? "N/A",
                "resourceName" : resourceName.text ?? "N/A", "time": timeStamp, "deletionDate" : delD ?? 0
                    ]) {err in
                        if let err = err {
                            print("The document was invalid for some reason? \(err)")
                        }
                        else{
                            print("Document added successfully.")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditResource"), object: nil)
                            self.dismiss(animated:true, completion:nil)
                        }

                        }
            }
        } 
    }
    
    @IBAction func homeAddButton(_ sender: Any) {
        let usersRef = db.collection("users")
        var fake = "false"
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    if document.documentID == self.userID {
                        if document.get("organization") as? String == "true"{
                            fake = "true"
                        }
                        else {
                            fake = "false"
                        }
                    }
                    
                }
            }
        }
        if(fake == "true") {
            imageLink.isHidden = false
            deletionDate.isHidden = false
            delDateLabel.isHidden = false
            nonOrgResDesc.isHidden = true
            performSegue(withIdentifier: "isOrg", sender: Any?.self)
        } else {
            imageLink.isHidden = true
            deletionDate.isHidden = true
            delDateLabel.isHidden = true
            nonOrgResDesc.isHidden = false
            performSegue(withIdentifier: "isOrg", sender: Any?.self)
        }
    }

    
    
    @IBAction func noOldDates(_ sender: Any) {
        let dtp = sender as! UIDatePicker
        if Date() <= dtp.date
        {
            print ("valid date")
        }
        else {
            dtp.date = Date()
            let alert = UIAlertController(title: "Error", message: "Deletion date is required to be after the current date", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
