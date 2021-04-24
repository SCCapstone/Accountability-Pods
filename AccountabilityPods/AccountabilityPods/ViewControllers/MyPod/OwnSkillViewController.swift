//
//  OwnSkillsViewController.swift
//  AccountabilityPods
//
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages the view that shows detailed description of a users own skill and lets them edit.

import UIKit
import Firebase
class OwnSkillViewController: UIViewController {
    
    // MARK: - Class Variables
    
    /// The firestore database
    let db = Firestore.firestore()
    /// Boolean value that changes when user is editing skill information.
    var userIsEditing: Bool = false
    /// Skill object (see Utilities for class info) passed to VC from table presenting user's skills
    var skill: Skill = Skill()
    
    // MARK: - UI Connectors
    
    /// Editable skill description 
    @IBOutlet weak var desc: UITextView!
    /// Editable skill name
    @IBOutlet weak var nameEdit: UITextField!
    /// Un-editable skill name label
    @IBOutlet weak var nameLabel: UILabel!
    /// Button that allows user to edit the skil info
    @IBOutlet weak var editButton: UIButton!
    /// Button that saves changed information to the database
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // set up skill name and description labels
        configureText()
    }
    
    /// Sets up description and name with information from passed skill object.
    func configureText()
    {
        desc.text = skill.desc
        nameLabel.text = skill.name
        nameEdit.isHidden = true
        doneButton.isHidden = true
    }
    
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - UI Functionality
    
    /// Allows user to edit skill information when button is pressed.
    ///
    /// - Parameter sender: the edit button 
    @IBAction func editResource(_ sender: Any) {
        // sends notification to skill viewer that skill has been edited
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditSkill"), object: nil)
            // change editing and hidden values
            userIsEditing = true
            nameLabel.isHidden = true
            editButton.isHidden = true
            doneButton.isHidden = false
            desc.isEditable = true
            // add name label text to name edit
            nameEdit.text = nameLabel.text
            nameLabel.isEnabled = false
            nameEdit.isEnabled = true
            nameEdit.isUserInteractionEnabled = true
            nameEdit.isHidden = false
            // cosmetically change the ui connectors to show that user is editing
            desc.layer.cornerRadius = 10
            desc.layer.backgroundColor = UIColor.systemGray6.resolvedColor(with: self.traitCollection).cgColor
            nameEdit.layer.borderWidth = 0
            nameEdit.layer.cornerRadius = 5
            nameEdit.layer.backgroundColor = UIColor.systemGray6.resolvedColor(with: self.traitCollection).cgColor
    
    }
    
    /// Completes editing and updates the skill in the database.
    ///
    /// - Parameter sender: the done button
    @IBAction func onDone(_ sender: Any) {
        // change hidden and enable features
        nameEdit.isHidden = true
        nameLabel.isHidden = false
        userIsEditing = false
        editButton.isHidden = false
        doneButton.isHidden = true
        editButton.tintColor = .black
        
        desc.isEditable = false
        nameLabel.text = nameEdit.text
        nameLabel.isEnabled = true
        nameEdit.isEnabled = false
        nameEdit.isUserInteractionEnabled = false
        // cosmetically change ui connectors to show editing is complete
        desc.layer.backgroundColor = UIColor.clear.cgColor
        // update the skill in the database
        db.document(skill.path).setData(["skillName" : nameLabel.text, "skillDescription" : desc.text]) {err in
            if let err = err {
                print(err)
            }
        }
    }
    
    /// Deletes the selected skill when trash button is pressed.
    ///
    /// - Parameter sender: the delete (trash) button
    @IBAction func onDelete(_ sender: Any) {
        // removes skill from database
        let docID = db.document(skill.path).documentID
        db.collection("users").document(Constants.User.sharedInstance.userID).collection("SKILLS").document((docID)).delete()
        // sends notification to skill table that skills have been edited
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditSkill"), object: nil)
        // closes the viewing screen since skill has been deleted
        self.dismiss(animated: true)
    }
    

}
