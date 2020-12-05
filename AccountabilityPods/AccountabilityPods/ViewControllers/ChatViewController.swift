//
//  ChatViewController.swift
//  AccountabilityPods
//
//  Created by KAHAN-THOMAS, JHADA L on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var userMsg: UITextField!
    let db = Firestore.firestore()
    
    var userID  = Constants.User.sharedInstance.userID;
    
    @IBOutlet weak var msgContain: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func txtDone(_ sender: Any) {
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewMsg"), object: nil)
        var ref = db.collection("users").document(userID).collection("MSG").addDocument(data: ["senderId" : userID, "message" : userMsg.text ?? "" ])
        {err in
        if let err = err {
            print("The document was invalid for some reason? \(err)")
        }
            else{
                print("Document added successfully.")
                self.dismiss(animated:true, completion:nil)
            }
        }
        userMsg.text = "Type Here..."
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

