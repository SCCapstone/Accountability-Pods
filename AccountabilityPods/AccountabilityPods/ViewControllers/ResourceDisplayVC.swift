//
//  ResourceDisplayVC.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
import Firebase
import UIKit

class ResourceDisplayVC: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var button: UIButton!
    let user = Constants.User.sharedInstance.userID
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var descField: UITextView!
    var docID: String? = nil
    var resource: Resource = Resource.init()
    var hasLiked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfLiked()
        setTextFields()
        // Do any additional setup after loading the view.
    }
    
    func setTextFields() {
        nameField.text = resource.name
        descField.text = resource.desc
        
        if(hasLiked)
        {
            self.textField.isEnabled = true
            self.textField.isHidden = false
            self.textField.isUserInteractionEnabled = true
            self.button.isEnabled = true
            self.button.isHidden = false
            self.button.isUserInteractionEnabled = true
            self.likeButton.tintColor = .systemPink
        }
        else
        {
            self.likeButton.tintColor = .lightGray
        }
        
    }
    func checkIfLiked()
    {
        db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").getDocuments() {
            docRefs,err in
            if let err = err {
                print("No documents found. \(err)")
                
            }
            else
            {
                for doc in docRefs!.documents {
                    if(doc.data()["docRef"] as! String == self.resource.path)
                    {
                        self.docID = doc.documentID
                        self.hasLiked = true
                        self.setTextFields()
                        return
                    }
                }
            }
        }
    }
    

    @IBAction func onLike(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnResourceDismissal"), object: nil)
        
        if(!hasLiked) {
            self.textField.isEnabled = true
            self.textField.isHidden = false
            self.textField.isUserInteractionEnabled = true
            self.button.isEnabled = true
            self.button.isHidden = false
            self.button.isUserInteractionEnabled = true
            let docRef = db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").addDocument(data: ["docRef" : self.resource.path]) {err in
            
                if let err = err {
                    print(err)
                    return
                }
            }
            self.docID = docRef.documentID
            self.hasLiked = true
            self.likeButton.tintColor = .systemPink
            return
        }
        else
        {
            self.textField.isEnabled = false
            self.textField.isHidden = true
            self.textField.isUserInteractionEnabled = false
            self.button.isEnabled = false
            self.button.isHidden = true
            self.button.isUserInteractionEnabled = false
            
            
            db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").document((self.docID)!).delete()
            self.hasLiked = false
            
            self.likeButton.tintColor = .lightGray
        }
        
        
        
    }
    @IBAction func createNewGroup(_ sender: Any) {
        
        let nameText = self.textField.text
        
        if(nameText == "")
        {
            
        }
        db.collection("users").document(user).collection("GROUPEDRESOURCES").getDocuments()
        {
            docs, err in
            if let err = err
            {
                print(err)
            }
            else
            {
                for doc in docs!.documents
                {
                    if doc.data()["folderName"] as! String == nameText
                    {
                        self.db.collection("users").document(self.user).collection("GROUPEDRESOURCES").document(doc.documentID).collection(nameText as! String).addDocument(data: ["resourceName" : self.nameField.text, "resourceDesc" : self.descField.text])
                        self.db.collection("users").document(self.user).collection("SAVEDRESOURCES").document(self.docID!).delete()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnResourceDismissal"), object: nil)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnGroupCreation"), object: nil)
                        return
                        
                    }
                    
                    
                    
                }
                self.db.collection("users").document(self.user).collection("GROUPEDRESOURCES").addDocument(data: ["folderName" : nameText!])
                {
                    err in
                    if let err = err
                    {
                        print(err)
                    }
                    else
                    {
                        self.createNewGroup(Any.self)
                    }
                    
                }
                
            }
        }
        
        
        
        
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
