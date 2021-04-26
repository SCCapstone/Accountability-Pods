//
//  ProfileViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages the first layer of another users profile page

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    // MARK: - Class Variables
    
    /// The name of the other user
    @IBOutlet weak var nameLabel: UILabel!
    /// The other users description
    @IBOutlet weak var descriptionLabel: UILabel!
    /// The inner page tabs to manage posts and skills
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    /// The container for the other users posts
    @IBOutlet weak var postContainer: UIView!
    /// The container for the other users skills
    @IBOutlet weak var skillsContainer: UIView!
    /// The username of the other user
    @IBOutlet weak var usernameLabel: UILabel!
    /// The button to add user as a contact
    @IBOutlet weak var addContactButton: UIButton!
    /// The button to remove user as a contact
    @IBOutlet weak var removeContactButton: UIButton!
    /// The profile object that has the other users info
    var profile = Profile()
    /// Variable that changes if the contact value changed
    var contactsChanged = false;
    /// The current users username
    var userID = Constants.User.sharedInstance.userID;
    /// The Firestore database
    let db = Firestore.firestore()
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Page only does light mode
        overrideUserInterfaceStyle = .light
        // Set elements to have the correct values
        setName()
        // Set contact to either add or remove depending on value in DB 
        setContactButton(addOrRemove: "start")
    }
    
    /// Hides keyboard when other spot on page is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    ///  Segues to either the resource or skill view depending on tap
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ProfileResourceViewController
        {
            vc.profile = self.profile
        }
        else if let vc = segue.destination as? ProfileSkillsViewController
        {
            vc.profile = self.profile
        }
        
    }
    /// Sets the name of the profile
    func setName() {
        nameLabel.text = profile.firstName + " " + profile.lastName
        usernameLabel.text = "@" + profile.uid
        descriptionLabel.text = profile.description
        
    }
    
    // MARK: - Manage contacts
    
    /// Enables the contact button if it is not the creator's profile. Additionally, switches between add and remove dependent on state
    func setContactButton(addOrRemove: String) {
        if profile.uid == userID {
            // if you are viewing your own profile you cannot add or remove as a contact
            addContactButton.alpha = 0
            removeContactButton.alpha = 0
        } else if (addOrRemove == "start") {
            print("starting contact")
            let docRef = db.collection("users").document(userID).collection("CONTACTS").document(profile.uid)
         
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // profile is already contact
                    self.addContactButton.alpha = 0
                    self.removeContactButton.alpha = 1
                    print("profile is contact")
                } else {
                    // profile is not yet a contact
                    self.addContactButton.alpha = 1
                    self.removeContactButton.alpha = 0
                    print("profile is not yet contact")
                }
            }
        }
        else if(addOrRemove == "add")
        {
            self.contactsChanged = !contactsChanged;
            print("got told to add")
            // profile is not yet a contact
            self.addContactButton.alpha = 0
            self.removeContactButton.alpha = 1
            print("profile is not yet contact")
        }
        else
        {
            self.contactsChanged = !contactsChanged;
            print("got told to remove")
            // profile is already contact
            self.addContactButton.alpha = 1
            self.removeContactButton.alpha = 0
            print("profile is contact")
        }
        
    }
    /// Used to add the contact to the user's saved contacts
    @IBAction func addContact(_ sender: Any) {
        db.collection("users").document(userID).collection("CONTACTS").document(profile.uid).setData(["userRef": profile.uid]) { err in
            if let err = err {
                print("Error adding contact: \(err)")
            } else {
                print("Contact added with uid: \(self.profile.uid)")
                self.setContactButton(addOrRemove: "add")
            }
        }
        
    }
    /// Lets the user remove the contact
    @IBAction func removeContact(_ sender: Any) {
        db.collection("users").document(userID).collection("CONTACTS").document(profile.uid).delete() { err in
            if let err = err {
                print("Error removing contact: \(err)")
            } else {
                print("Contact successfully removed")
                self.setContactButton(addOrRemove: "remove")
                
            }
            
        }
    }

    // MARK: - Segmented Control display
    
    /// Used to display the containers for resources and skills
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1, animations: {
            self.postContainer.alpha = 1;
            self.skillsContainer.alpha = 0;
        })
    }
    /// Don't refresh the contacts view unless contacts actually get changed
    override func viewDidDisappear(_ animated: Bool) {
        if(contactsChanged)
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
        }
    }
    
    /// Manages what happens when segmented control is pressed
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.postContainer.alpha = 1;
                self.skillsContainer.alpha = 0;
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.postContainer.alpha = 0;
                self.skillsContainer.alpha = 1;
            })
        }
        
    }
    
}
