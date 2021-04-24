//
//  AddSkillViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

class AddSkillViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    // MARK: - UI Connectors
    
    /// The stack that contains the skill name and description.
    @IBOutlet weak var addSkillStackView: UIStackView!
    /// The user entered name for the skill.
    @IBOutlet weak var skillNameTextField: UITextField!
    /// The user entered description for the skill.
    @IBOutlet weak var skillDescriptionTextField: UITextView!
    /// The button to add the user entered skill to the users profile.
    @IBOutlet weak var doneAddingButton: UIButton!
    
    // MARK: - Class Variables
    
    /// The firestore database
    let db = Firestore.firestore()
    /// The username of the current user
    var userID = Constants.User.sharedInstance.userID;
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // associate text fields with text field delegate
        skillDescriptionTextField.delegate = self
        skillNameTextField.delegate = self
        // make cosmetic design changes to text field
        editBoxes()
    }
    
    /// Makes cosmetic changes to the name and description text fields
    func editBoxes() {
        skillNameTextField.layer.cornerRadius = 15
        skillDescriptionTextField.layer.cornerRadius = 15
    }
    
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Text field functionality
    
    /// Removes placeholder text when user begins editing description.
    ///
    /// Parameter textView: the skill description text view
    func textViewDidBeginEditing(_ textView: UITextView) {
        skillDescriptionTextField.text = ""
    }
    /// Replaces empty description text with placeholder when tapped away from editing.
    ///
    /// Parameter textView: the skill description text view
    func textViewDidEndEditing(_ textView: UITextView) {
        if skillDescriptionTextField.text == "" {
            skillDescriptionTextField.text = "Skill description ..."
        }
        
    }
    /// Replaces empty skill name text when user taps away from editing
    ///
    /// Parameter textField: the skill name text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        // clear fields
        if skillNameTextField.text == "" {
            skillNameTextField.text = "Skill name ..."
        }
        
    }
    
    /// Adds new user entered skill to database
    ///
    /// Paramter sender: the tapped object
    @IBAction func donePressed(_ sender: Any) {
        // sends notification to OwnSkillViewController that the own skills table needs to be updated.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditSkill"), object: nil)
        // update the SKILLS collection in the database
        _ = db.collection("users").document(userID).collection("SKILLS").addDocument(data: [
                        "creatorRef" : userID,
                        "skillName" : skillNameTextField.text ?? "N/A",
                        "skillDescription" : skillDescriptionTextField.text ?? "N/A"
                    ])
        {err in
                        if let err = err {
                            print("The document was invalid for some reason? \(err)")
                        }
                        else{
                            print("Document added successfully.")
                            self.dismiss(animated:true, completion:nil)
                        }

        }
        skillNameTextField.text = "Skill name ..."
        skillDescriptionTextField.text = "Skill description ..."
    }
      

}
