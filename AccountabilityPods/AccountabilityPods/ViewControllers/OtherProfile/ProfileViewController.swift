//
//  ProfileViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var postContainer: UIView!
    @IBOutlet weak var skillsContainer: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var removeContactButton: UIButton!
    
    var profile = Profile()
    var contactsChanged = false;
    var userID = Constants.User.sharedInstance.userID;
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setName()
        setContactButton(addOrRemove: "start")
     
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // segues to either the resource or skill view
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
    // Sets the name of the profile
    func setName() {
        nameLabel.text = profile.firstName + " " + profile.lastName
        usernameLabel.text = "@" + profile.uid
        descriptionLabel.text = profile.description
        
    }
    // Enables the contact button if it is not the creator's profile. Additionally, switches between add and remove dependent on state
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
    // Used to add the contact to the user's saved contacts
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
    // Lets the user remove the contact
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

    // Used to display the containers for resources and skills
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1, animations: {
            self.postContainer.alpha = 1;
            self.skillsContainer.alpha = 0;
        })
    }
    // Don't refresh the contacts view unless contacts actually get changed
    override func viewDidDisappear(_ animated: Bool) {
        if(contactsChanged)
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
        }
    }
    
    
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
