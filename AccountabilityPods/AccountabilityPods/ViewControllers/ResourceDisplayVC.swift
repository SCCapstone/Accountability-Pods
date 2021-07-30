//
//  ResourceDisplayVC.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
import Firebase
import UIKit
// Purpose of this view is to display resources, as well as having a like button and a link to the creator's profile
class ResourceDisplayVC: UIViewController {
    let db = Firestore.firestore()
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var imageField: UIImageView!
    @IBOutlet weak var nonOrgDescField: UITextView!
    // Variables used for more efficient loading
    var docID: String? = nil
    var id: String? = nil
    var needsLoad = false
    var resource: ResourceHashable = Resource.init().makeHashableStruct()
    var hasLiked: Bool = false
    var profile = Profile()
    var fake = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Observer is to check if asynchronous operations on loading profile is complete
        NotificationCenter.default.addObserver(self, selector: #selector(self.onProfileComplete), name: NSNotification.Name(rawValue: "ProfileAsyncFinished"), object: nil)

        let usersRef = db.collection("organizations")
        let directories = resource.path.split(separator: "/")
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            }
            else {
        for document in querySnapshot!.documents {
            if document.documentID == directories[1] {
                self.fake = 1
            }
            else {
                self.fake = 0
            }
            
        
        }
    }
            print(self.fake)
            print(directories[1])
            if(self.fake == 1) {
            print("0a")
            self.imageField.isHidden = false
            self.descField.isHidden = false
            self.nonOrgDescField.isHidden = true
            self.setImgField()
        } else {
            print("1a")
            self.imageField.isHidden = true
            self.descField.isHidden = true
            self.nonOrgDescField.isHidden = false
        }
    }

        
        checkResourceStillValid()
        // Do any additional setup after loading the view.
    }
    // This function is meant for saved resources to determine if the path that they received is still valid-- if not, hides like button, profile button, etc.
    // Additionally displays an error message. If it no longer exists, it gets removed. Additionally, if the path is already invalid and would cause an error,
    // it removes the resource reference and immediately dismisses the view.
    func checkResourceStillValid()
    {
        if(resource.path.count <= 5)
        {
            self.db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").document((self.docID)!).delete()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SavedResourceChange"), object: nil)
            self.dismiss(animated: true)
            
        }
        else
        {
        db.document(resource.path).getDocument() {
            docRef, err in
            if let err = err {
                print(err.localizedDescription)
                
            }
            else
            {
                print("loaded resource")
                if(docRef == nil || !docRef!.exists)
                {
                    print("test")
                    self.nameField.text = "Resource Not Found"
                    self.descField.text = "The resource you have checked no longer exists. Sorry about that!"
                    self.nonOrgDescField.text = "The resource you have checked no longer exists. Sorry about that!"
                    self.likeButton.isHidden = true
                    self.usernameButton.isHidden = true
                    if(self.hasLiked)
                    {
                        self.db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").document((self.docID)!).delete()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SavedResourceChange"), object: nil)
                        return;
                    }
                }
                self.checkIfLiked()
                self.setTextFields()
            }
        }
    }
    }
    
    func setImgField() {
        let directories = resource.path.split(separator: "/")
        var imgUrl = ""
        let usrName = "" + directories[1]
        var orgDocID = ""
        if(imageField.isHidden == false) {
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
                        if (document.get("resourceName") as? String == self.nameField.text) {
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
                                    self.imageField.image = imageDown
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
    
    // Sets the textfields of the resource from the provided resource
    func setTextFields() {
        nameField.text = resource.name
        nonOrgDescField.text = resource.desc
        descField.text = resource.desc
        let directories = resource.path.split(separator: "/")
        //print("" + directories[1])
        usernameButton.setTitle(("@" + directories[1]), for: UIControl.State.normal)
        
        if(hasLiked)
        {
            self.likeButton.tintColor = .systemPink
        }
        else
        {
            self.likeButton.tintColor = .lightGray
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // Prepare to transition to the creator's profile on click
    @IBAction func onClickUsername(_ sender: Any) {
        print("username clicked")
        let user = resource.path.split(separator:"/")[1]
        // Ensure that this can only trigger if a profile has to be loaded, to avoid issues related to notifications
        needsLoad = true;
        self.profile = Profile(base:db, path_: ("users/" + user))
    }
    // This is the function that actually transitions, and sets needsLoad back to false to ensure it does not get called until clicked again
    @objc func onProfileComplete() {
        print("test")
        if(needsLoad)
        {
            needsLoad = false;
        performSegue(withIdentifier: "showProfileSegue", sender: Any?.self)
        }
        
    }
    // Sets the destination profile's information
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showProfileSegue")
        {
            if let dView = segue.destination as? ProfileViewController
            {
            dView.profile = self.profile
            }
            
        }
    }
    // Function that determines if the resource is actually saved/liked. If it is, continue on to setting text.
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

    // Whenever the like button is pressed, it either unsaves or saves the resource, changing the tint
    // Saved resource gets a reference added to the user's saved resources
    @IBAction func onLike(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SavedResourceChange"), object: nil)
        
        if(!hasLiked) {
 
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
 
            db.collection("users").document(Constants.User.sharedInstance.userID).collection("SAVEDRESOURCES").document((self.docID)!).delete()
            self.hasLiked = false
            
            self.likeButton.tintColor = .lightGray
        }
        
    }

}
