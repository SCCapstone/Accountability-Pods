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
    var userID = Constants.User.sharedInstance.userID;
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setName()
        setContactButton()

        // Do any additional setup after loading the view.
    }
    
    func setName() {
        nameLabel.text = profile.firstName + " " + profile.lastName
        usernameLabel.text = "@" + profile.userName
        descriptionLabel.text = profile.description
        
    }
    
    func setContactButton() {
        if profile.uid == userID {
            // if you are viewing your own profile you cannot add or remove as a contact
            addContactButton.alpha = 0
            removeContactButton.alpha = 0
        } else {
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
        
    }
    
    @IBAction func addContact(_ sender: Any) {
        db.collection("users").document(userID).collection("CONTACTS").document(profile.uid).setData(["userRef": profile.uid]) { err in
            if let err = err {
                print("Error adding contact: \(err)")
            } else {
                print("Contact added with uid: \(self.profile.uid)")
                self.setContactButton()
            }
        }
        
    }
    @IBAction func removeContact(_ sender: Any) {
        db.collection("users").document(userID).collection("CONTACTS").document(profile.uid).delete() { err in
            if let err = err {
                print("Error removing contact: \(err)")
            } else {
                print("Contact successfully removed")
                self.setContactButton()
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1, animations: {
            self.postContainer.alpha = 1;
            self.skillsContainer.alpha = 0;
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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