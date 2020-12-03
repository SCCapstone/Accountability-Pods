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

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var MyPostsContainer: UIView!
    @IBOutlet weak var SavedPostsContainer: UIView!
    @IBOutlet weak var PodGroupsContainer: UIView!
    @IBOutlet weak var SkillsContainer: UIView!
    @IBOutlet weak var NameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setName()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1, animations: {
            self.MyPostsContainer.alpha = 1;
            self.SavedPostsContainer.alpha = 0;
            self.PodGroupsContainer.alpha = 0;
            self.SkillsContainer.alpha = 0;
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
    func setName() {
        let user = Auth.auth().currentUser
        if let user = user {
          // The user's ID, unique to the Firebase project.
          // Do NOT use this value to authenticate with your backend server,
          // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            let db = Firestore.firestore()
            let userRef = db.collection("users").whereField("uid", isEqualTo: uid)
            userRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let firstname: String? = document.get("firstname") as? String
                    let lastname: String? = document.get("lastname") as? String
                    let firstnameUnwrapped = firstname ?? "Unknown"
                    let lastnameUnwrapped = lastname ?? "Unknown"
                    let name = firstnameUnwrapped + " " + lastnameUnwrapped
                    self.NameLabel.alpha = 1
                    self.NameLabel.text = name
                    
                }
            }
                
            }
            
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
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
