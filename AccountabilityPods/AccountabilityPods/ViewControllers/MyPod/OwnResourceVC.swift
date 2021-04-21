//
//  OwnResourceVC.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class OwnResourceVC: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var nameEdit: UITextField!
    var userIsEditing: Bool = false
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    var resource: Resource = Resource()
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        configureText()
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func configureText()
    {
        desc.text = resource.desc
        nameLabel.text = resource.name
        doneButton.isHidden = true
    }
    
    @IBAction func editResource(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditResource"), object: nil)
        overrideUserInterfaceStyle = .light
        userIsEditing = true
        nameLabel.isHidden = true
        
        editButton.isHidden = true
        doneButton.isHidden = false
        //edit button blue
        
        desc.isEditable = true
        nameEdit.text = nameLabel.text
        nameLabel.isEnabled = false
        nameEdit.isEnabled = true
        nameEdit.isUserInteractionEnabled = true
        nameEdit.isHidden = false
        desc.layer.cornerRadius = 10
        desc.layer.backgroundColor = UIColor.systemGray6.resolvedColor(with: self.traitCollection).cgColor
        nameEdit.layer.borderWidth = 0
        nameEdit.layer.cornerRadius = 5
    }
    @IBAction func onDone(_ sender: Any) {
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
        db.document(resource.path).setData(["resourceName" : nameLabel.text, "resourceDesc" : desc.text]) {err in
            if let err = err {
                print(err)
            }
        }
    }
    
    
    @IBAction func onDelete(_ sender: Any) {
        let docID = db.document(resource.path).documentID
        db.collection("users").document(Constants.User.sharedInstance.userID).collection("POSTEDRESOURCES").document((docID)).delete()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditResource"), object: nil)
        self.dismiss(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
