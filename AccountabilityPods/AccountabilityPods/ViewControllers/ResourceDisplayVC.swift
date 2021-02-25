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
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var descField: UITextView!
    var docID: String? = nil
    var resource: ResourceHashable = Resource.init().makeHashableStruct()
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
        let directories = resource.path.split(separator: "/")
        //print("" + directories[1])
        usernameButton.setTitle(("@" + directories[1]), for: UIControl.State.normal)
        
        if(hasLiked)
        {
            self.groupButton.isHidden = false;
            self.groupButton.isUserInteractionEnabled = true;
            self.groupName.isHidden = false;
            self.likeButton.tintColor = .systemPink
        }
        else
        {
            self.groupButton.isHidden = true;
            self.groupButton.isUserInteractionEnabled = false;
            self.groupName.isHidden = true;
            self.likeButton.tintColor = .lightGray
            
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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

    @IBAction func onGroupButton(_ sender: Any) {
        
        
            let docRef = db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").getDocuments(){
                docs, error in
                if let error = error
                {
                    print(error)
                }
                else
                {
                    for doc in docs!.documents {
                        if(doc.data()["docRef"] as! String == self.resource.path)
                        {
                            doc.reference.setData(["groupName" : self.groupName.text], merge: true)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SavedResourceChange"), object: nil)
                        }
                    }
                }
                
            }
        
        
        
    }
    @IBAction func onLike(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SavedResourceChange"), object: nil)
        
        if(!hasLiked) {
            self.groupButton.isHidden = false;
            self.groupButton.isUserInteractionEnabled = true;
            self.groupName.isHidden = false;
            let docRef = db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").addDocument(data: ["docRef" : self.resource.path, "groupName": ""]) {err in
            
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
            self.groupButton.isHidden = true;
            self.groupButton.isUserInteractionEnabled = false;
            self.groupName.isHidden = true;
            db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").document((self.docID)!).delete()
            self.hasLiked = false
            
            self.likeButton.tintColor = .lightGray
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
