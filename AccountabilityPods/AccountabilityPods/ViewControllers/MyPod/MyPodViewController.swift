//
//  MyPodViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MyPodViewController: UIViewController {
     //ADDED
    let db = Firestore.firestore()
    let userID = Constants.User.sharedInstance.userID;
    //HERE
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var MyPostsContainer: UIView!
    @IBOutlet weak var SavedPostsContainer: UIView!
    @IBOutlet weak var PodGroupsContainer: UIView!
    @IBOutlet weak var SkillsContainer: UIView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var editDescButton: UIButton!
    @IBOutlet weak var addDescButton: UIButton!
    @IBOutlet weak var editDescriptionText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setName()
        
        //added
        //let users = db.collection("USERS");
        //let userDoc = users.document(userID);
        
        // unti here
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // show myPosts tab when pods tab chosen
        UIView.animate(withDuration: 0.1, animations: {
            self.MyPostsContainer.alpha = 1;
            self.SavedPostsContainer.alpha = 0;
            self.PodGroupsContainer.alpha = 0;
            self.SkillsContainer.alpha = 0;
        })
    }
    @IBAction func onEditDescription(_ sender: Any) {
       self.editDescriptionText.alpha = 1;
        self.descriptionLabel.alpha = 0;
        self.editDescButton.alpha = 0;
        self.addDescButton.alpha = 1;
        self.editDescriptionText.text = descriptionLabel.text
    }
    
    @IBAction func onAddDescription(_ sender: Any) {
        self.editDescButton.alpha = 1;
        self.addDescButton.alpha = 0;
        self.editDescriptionText.alpha = 0;
        self.descriptionLabel.alpha = 1;
        db.collection("users").document(userID).updateData(["description": editDescriptionText.text!])
        setName()
        print(userID)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setName() {
        // setting description as invisibile (edit later!)
        // get current userID
        let uid = Constants.User.sharedInstance.userID
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        _ = userRef.addSnapshotListener() {
            document, err in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else
            {
                
                let firstname = document!.get("firstname") as! String
                let lastname = document!.get("lastname") as! String
                let username = document!.get("username") as! String
                let description = document!.get("description") as! String
                   
                    let name = firstname + " " + lastname
                    self.NameLabel.alpha = 1
                    self.editDescriptionText.alpha = 0;
                    self.descriptionLabel.alpha = 1
                    self.editDescButton.alpha = 1;
                    self.addDescButton.alpha = 0;
                    self.NameLabel.text = name
                    self.descriptionLabel.text = description
                    self.usernameLabel.text = "@" + username
            
        }
        
      
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
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
    
}

