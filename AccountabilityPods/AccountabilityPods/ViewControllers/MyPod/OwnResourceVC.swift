//
//  OwnResourceVC.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages the view that displays a users resource and allows the user to edit or delete the resource.

import UIKit
import Firebase
class OwnResourceVC: UIViewController {
    
    // MARK: - Class Variables
    
    /// The firestore database.
    let db = Firestore.firestore()
    /// Boolean value that changes if user is editing the resource.
    var userIsEditing: Bool = false
    /// The resource object with the post information passed from the table in which the post was tapped.
    var resource: Resource = Resource()
    
    // MARK: - UI Connectors
    
    /// The desciption of a post being viewed.
    @IBOutlet weak var desc: UITextView!
    /// The editable name of a post being viewed.
    @IBOutlet weak var nameEdit: UITextField!
    /// The uneditable name of a post being viewed.
    @IBOutlet weak var nameLabel: UILabel!
    /// The button that the user presses to edit the post content.
    @IBOutlet weak var editButton: UIButton!
    /// The button that for user to save edits.
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // set name and description
        configureText()
    }
    
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Sets name and description to values in the passed resource object.
    func configureText()
    {
        desc.text = resource.desc
        nameLabel.text = resource.name
        // initially hide done button
        doneButton.isHidden = true
    }
    
    // MARK: - UI Functionality
    
    /// Allows user to edit resource name and description with edit button is pressed.
    ///
    /// - Parameter sender: the edit button that was tapped
    @IBAction func editResource(_ sender: Any) {
        // sends notification to own post display that a resource has been edited.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditResource"), object: nil)
        // sets interface to light mode
        overrideUserInterfaceStyle = .light
        // change editing value
        userIsEditing = true
        nameLabel.isHidden = true
        
        // enable correct buttons
        editButton.isHidden = true
        doneButton.isHidden = false
        
        desc.isEditable = true
        nameEdit.text = nameLabel.text
        nameLabel.isEnabled = false
        nameEdit.isEnabled = true
        nameEdit.isUserInteractionEnabled = true
        nameEdit.isHidden = false
        
        // cosmetically edit the the text views and fields
        desc.layer.cornerRadius = 10
        desc.layer.backgroundColor = UIColor.systemGray6.resolvedColor(with: self.traitCollection).cgColor
        nameEdit.layer.borderWidth = 0
        nameEdit.layer.cornerRadius = 5
    }
    
    /// Updates text fields and views, and the database with the edited post.
    @IBAction func onDone(_ sender: Any) {
        // Update text fields to finish editing
        overrideUserInterfaceStyle = .light
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
        desc.layer.backgroundColor = UIColor.white.cgColor
        // Update resource information in the database
        db.document(resource.path).setData(["resourceName" : nameLabel.text ?? "", "resourceDesc" : desc.text ?? ""]) {err in
            if let err = err {
                print(err)
            }
        }
    }
    
    /// Deletes resource from database when delete button is pressed.
    ///
    /// - Parameter sender: the delete button that was pressed
    @IBAction func onDelete(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Post", message: "Would you like to delete your post?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
                do {
                
                    self.dismiss(animated:true, completion: {
                        let docID = self.db.document(self.resource.path).documentID
                    self.db.collection("users").document(Constants.User.sharedInstance.userID).collection("POSTEDRESOURCES").document((docID)).delete()
                    // send notication to the users own post resource display that a resources have changed
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditResource"), object: nil)
                    // close the opened display because post has been deleted
                    self.dismiss(animated: true)
                })
                }
            }))
        alertController.addAction(UIAlertAction(title:"No", style: .default, handler: nil))
        self.present(alertController, animated: true)
        
    }



}

