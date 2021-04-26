//
//  SignUpViewController.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    // MARK: - Class Variables
    
    ///  The Firesetore database
    let db = Firestore.firestore()
    let userID = Constants.User.sharedInstance.userID;
    // MARK: - UI Connectors
   
    /// The user entered email
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var editNameTextfield: UITextField!
    @IBOutlet weak var editDescriptionTextview: UITextView!

    @IBOutlet weak var learnMorePopup: UIButton!
    @IBOutlet weak var accountIsPrivate: UISwitch!
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        setName()
        // Initializes switch button to on if user is already private, off if user is not
        let docRef = db.collection("users").document(userID)
        docRef.getDocument { (document,error) in
            if let document = document, document.exists {
                let privateVar = document.get("private") as? Int ?? 0
                if (privateVar == 0){
                    self.accountIsPrivate.isOn = false
                }
                else {
                    self.accountIsPrivate.isOn = true
                }
            }
            else {
                print("couldn't get private field from user")
                return
            }
            
        }
    }
    // MARK: Edit and Update Button Switch On Tap
   
    /// When edit is pressed, hides labels and shows text fields to allow a user to edit name & description
    @IBAction func onEditPressed(_ sender: Any) {
        self.editNameTextfield.alpha=1;
        self.nameLabel.alpha=0;
        self.editDescriptionTextview.alpha=1;
        self.descriptionLabel.alpha=0;
        self.updateButton.alpha=1;
        self.editButton.alpha=0;
        self.editDescriptionTextview.text = descriptionLabel.text
        self.editNameTextfield.text=nameLabel.text
    }
    /// When update is pressed, hides textfields and shows updated name & description labels
    @IBAction func onUpdatePressed(_ sender: Any) {
        self.editNameTextfield.alpha=0;
        self.nameLabel.alpha=1;
        self.editDescriptionTextview.alpha=0;
        self.descriptionLabel.alpha=1;
        self.updateButton.alpha=0;
        self.editButton.alpha=1;
        /// Updates a users description in firestore
        db.collection("users").document(userID).updateData(["description": editDescriptionTextview.text!])
        let fullname = editNameTextfield.text!
        var components = fullname.components(separatedBy: " ")
        var firstName = " "
        var lastName = " "
        if components.count > 0 {
            firstName = components.removeFirst()
            lastName = components.joined(separator: " ")
        }
        else {
            print("Add first and last name seperated by a space")
        }
        /// Updates a users name in firestore
        db.collection("users").document(userID).updateData(["firstname": firstName, "lastname": lastName])
        setName()
    }
    
    func setName() {
        let uid = Constants.User.sharedInstance.userID
        let db = Firestore.firestore()
        /// retrieve users collection in firestore by userID
        let userRef = db.collection("users").document(uid)
        
        _ = userRef.addSnapshotListener() {
            document, err in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else
            {
                /// retrieving updated name and description
                let firstname = document!.get("firstname") as! String
                let lastname = document!.get("lastname") as! String
                let description = document!.get("description") as! String
                   
                    /// labels appear on update
                    let name = firstname + " " + lastname
                    self.nameLabel.alpha = 1;
                    self.nameLabel.text = name
                    self.descriptionLabel.alpha = 1;
                    self.descriptionLabel.text = description
                    self.editButton.alpha = 1;
                
                    /// textboxes to edit dont appear yet
                    self.updateButton.alpha = 0;
                    self.editNameTextfield.alpha = 0;
                    self.editDescriptionTextview.alpha = 0;
            }
        }
    }
    // MARK: Make Account Private Button
   
    /// Sets user to private when switch is set to on
    @IBAction func makeAccountPrivateSwitch_Pressed(_ sender: Any) {
        if ((sender as AnyObject).isOn == true) {
            db.collection("users").document(userID).updateData(["private": 1])
                  } else {
                    db.collection("users").document(userID).updateData(["private": 0])
                  }
    }
    ///Learn more button is pressed -> adds alert that provides user with info about private account functionality 
    @IBAction func learnMoreButton_Pressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Learn More", message: "By making your account private, no one can find or view you're profile", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

