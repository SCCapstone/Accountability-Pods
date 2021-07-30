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
    /// If the account is an org or not
    var isOrg: Int = 2
    
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
    /// The user inputted image (org accounts only)
    @IBOutlet weak var imgView: UIImageView!
    /// The description of a post being viewed (org accounts)
    @IBOutlet weak var orgDesc: UITextView!
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
        orgDesc.text = resource.desc
        nameLabel.text = resource.name
        // initially hide done button
        doneButton.isHidden = true
        let usersRef = db.collection("organizations")
        let directories = resource.path.split(separator: "/")
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            }
            else {
        for document in querySnapshot!.documents {
            if document.documentID == directories[1] {
                self.isOrg = 1
            }
            else {
                self.isOrg = 0
            }
            
        
        }
    }
            print(self.isOrg)
            print(directories[1])
            if(self.isOrg == 1) {
            print("0a")
            self.imgView.isHidden = false
            self.desc.isHidden = true
            self.orgDesc.isHidden = false
            self.setImgField()
        } else {
            print("1a")
            self.imgView.isHidden = true
            self.desc.isHidden = false
            self.orgDesc.isHidden = true
        }
    }
    }
    
    func setImgField() {
        let directories = resource.path.split(separator: "/")
        var imgUrl = ""
        let usrName = "" + directories[1]
        var orgDocID = ""
        if(imgView.isHidden == false) {
            print("0x")
            let findDocID = db.collection("organizations").document(usrName).collection("POSTEDRESOURCES")
            print("1x")
            findDocID.getDocuments() {(QuerySnapshot, err) in
                if let err = err {
                    print("Error: \(err)")
                }
                else {
                    for document in QuerySnapshot!.documents {
                        print("2x")
                        if (document.get("resourceName") as? String == self.nameLabel.text) {
                            print("3x")
                            orgDocID = (document.documentID as String)
                        }
                    }
                    }
                }
            }
        print("4x")
        let usersRef = db.collection("organizations").document(usrName).collection("POSTEDRESOURCES")
            usersRef.getDocuments() {(QuerySnapshot, err) in
                if let err = err {
                    print("Error: \(err)")
                }
                else {
                    for document in QuerySnapshot!.documents {
                        if(document.documentID == orgDocID) {
                            imgUrl = document.get("imageLink") as! String
                            print("\n\n\n\n" + imgUrl + "\n\n\n\n\n")
                        }
                    }
        }
                let urls = URL(string: imgUrl)!
            let session = URLSession(configuration: .default)
                let downloadPic = session.dataTask(with: urls) { Data,URLResponse,Error in
                    if let e = Error {
                        print("Error downloading picture: \(e)")
                    } else {
                        if let res = URLResponse as? HTTPURLResponse {
                            print("Downloaded picture with response: \(res.statusCode)")
                            if let imageData = Data {
                                let imageDown = UIImage(data: imageData)
                                print("work")
                                DispatchQueue.main.async {
                                    self.imgView.image = imageDown
                                }
                                print("works")
                            } else {
                                print("Couldn't get image: Image is nil")
                            }
                        } else {
                            print("Couldn't get a response code")
                        }
                    }
                }
                
                downloadPic.resume()
        }
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
                        if(self.isOrg == 1) {
                            self.db.collection("organization").document(Constants.User.sharedInstance.userID).collection("POSTEDRESOURCES").document((docID)).delete()
                        }
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

