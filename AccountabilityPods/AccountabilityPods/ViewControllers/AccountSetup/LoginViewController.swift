//
//  LoginViewController.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

   /* @IBAction func prevViewButtonPressed(_ sender: Any) {
        print("Button pressed")
        self.performSegue(withIdentifier: "backToHomeFromLogin", sender: self)
    }*/
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var enterButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
       let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction=UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
        // Do any additional setup after loading the view.
        setUpElements()

    }
    
    func setUpElements() {
        errorLabel.alpha = 0 // hide error label
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func checkFields() -> String? {
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "please enter values for all boxes"
        }
        
        return nil
    }

    func editErrorMessage (_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
        
    }
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? UITabBarController
        
           
           view.window?.rootViewController = homeViewController
           view.window?.makeKeyAndVisible()
           
    }
    @IBAction func enterTapped(_ sender: Any) {
        // check text fields
        let errorValue = checkFields()
        if errorValue != nil {
            editErrorMessage(errorValue!)
        }
        // sign in user
        else {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
                if error != nil {
                    self.editErrorMessage(error!.localizedDescription)
                }
                else {
                    
                    self.db.collection("userids").getDocuments() { docs, err in
                    if let err = err {
                        print(err)
                    }
                    else
                    {
                        for doc in docs!.documents {
                            if (doc.documentID == result!.user.uid)
                            {
                                print("Successfully got the username from ID!")
                                Constants.User.sharedInstance.userID = doc.data()["username"] as! String
                                
                                UserDefaults.standard.setValue(doc.documentID, forKey: "userID")
                                UserDefaults.standard.setValue(UUID().uuidString, forKey: "sessID")
                                self.db.collection("userids").document(result!.user.uid).setData(["sessionID": UserDefaults.standard.string(forKey: "sessID")!], merge:true)
                                self.transitionToHome()
                            }
                        }
                        print("Error getting username from ID.")
                    }
                    }
                    //Constants.User.sharedInstance.userID = result!.user.uid;
                    //print(Constants.User.sharedInstance.userID)
                    
                }
            }    }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   
    
}

