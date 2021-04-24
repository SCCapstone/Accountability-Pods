//
//  MyPodViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages the own profile view and tabs for the subviews.

import UIKit
import Firebase
import FirebaseAuth

class MyPodViewController: UIViewController {
    // MARK: - Class Variables
    
    /// The firestore database
    let db = Firestore.firestore()
    /// The current users username
    let userID = Constants.User.sharedInstance.userID;
    
    // MARK: - UI Connectors
     
    /// The subview tab controller. 
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    /// The subview with users own posts.
    @IBOutlet weak var MyPostsContainer: UIView!
    /// The subview with collection of posts saved by the user.
    @IBOutlet weak var SavedPostsContainer: UIView!
    /// The subview with a collection of the users contacts.
    @IBOutlet weak var PodGroupsContainer: UIView!
    /// The subview with user's skill and skill creation.
    @IBOutlet weak var SkillsContainer: UIView!
    /// The label for the users first and last name.
    @IBOutlet weak var NameLabel: UILabel!
    /// The label for the users username
    @IBOutlet weak var usernameLabel: UILabel!
    /// The label for the users profile description
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // set up the labels at the top of page
        setName()
    }
    
    /// Sets which subview first appears depending on which sub tab is selected
    ///
    /// - Parameter animated: whether animation is enabled
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // case relates to position of selected tab
        // switches which view is showed depending on case
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.MyPostsContainer.alpha = 1;
            self.SavedPostsContainer.alpha = 0;
            self.PodGroupsContainer.alpha = 0;
            self.SkillsContainer.alpha = 0;
        case 1:
            self.MyPostsContainer.alpha = 0;
            self.SavedPostsContainer.alpha = 1;
            self.PodGroupsContainer.alpha = 0;
            self.SkillsContainer.alpha = 0;
        case 2:
            self.MyPostsContainer.alpha = 0;
            self.SavedPostsContainer.alpha = 0;
            self.PodGroupsContainer.alpha = 1;
            self.SkillsContainer.alpha = 0;
        case 3:
            self.MyPostsContainer.alpha = 0;
            self.SavedPostsContainer.alpha = 0;
            self.PodGroupsContainer.alpha = 0;
            self.SkillsContainer.alpha = 1;
        default:
                break
        }
    }
  
    /// Set up name, username, and description label shown at the top of the page
    func setName() {
        // get current userID, and database
        let uid = Constants.User.sharedInstance.userID
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        // get document for current user
        _ = userRef.addSnapshotListener() {
            document, err in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else
            {
                // gets information of database
                let firstname = document!.get("firstname") as! String
                let lastname = document!.get("lastname") as! String
                let username = document!.get("username") as! String
                let description = document!.get("description") as! String
                
                // format name         
                let name = firstname + " " + lastname
                //  update the labels
                self.NameLabel.alpha = 1;
                self.descriptionLabel.alpha = 1;
                self.NameLabel.text = name
                self.descriptionLabel.text = description
                self.usernameLabel.text = "@" + username
            
             }
        }
    }
    
    /// Sets keyboard to hide when screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - UI Actions
    
    /// Changes subview depending on which tab is selected
    ///
    /// - Parameter sender: the segmented control tab bar
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        // controls which tab within the tab is shown
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.MyPostsContainer.alpha = 1;
                self.SavedPostsContainer.alpha = 0;
                self.PodGroupsContainer.alpha = 0;
                self.SkillsContainer.alpha = 0;
            })
        } else if sender.selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.5, animations: {
                self.MyPostsContainer.alpha = 0;
                self.SavedPostsContainer.alpha = 1;
                self.PodGroupsContainer.alpha = 0;
                self.SkillsContainer.alpha = 0;
            })
        } else if sender.selectedSegmentIndex == 2 {
            UIView.animate(withDuration: 0.5, animations: {
                self.MyPostsContainer.alpha = 0;
                self.SavedPostsContainer.alpha = 0;
                self.PodGroupsContainer.alpha = 1;
                self.SkillsContainer.alpha = 0;
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.MyPostsContainer.alpha = 0;
                self.SavedPostsContainer.alpha = 0;
                self.PodGroupsContainer.alpha = 0;
                self.SkillsContainer.alpha = 1;
            })
        }
    }
     
    /// Shows a pop up that explains how to use the messaging page.
    ///
    /// - Parameter sender: the tapped object
    @IBAction func helpTapped(_ sender: Any) {
        // prepares and presents pop up
        let alertController = UIAlertController(title: "My Profile Help", message: "View and edit your own posts, view and delete saved posts, view and organize contacts, add and remove skills\nTap settings in top right to change name and description or view tutorial for more detailed information", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    
}

