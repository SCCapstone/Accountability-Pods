//
//  SignUpViewController.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var firstnameTextField: UITextField!
    
    @IBOutlet weak var lastnameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var accountIsPrivate: UISwitch!
    
    @IBOutlet weak var learnMore: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        setUpElements()
    }
    func setUpElements() {
        errorLabel.alpha = 0 // hide error label
        self.accountIsPrivate.isOn = false
    }
    @IBAction func learnMoreButton_Pressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Learn More", message: "By making your account private, no one can find or view you're profile", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)
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
        // check if all text fields have text
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            firstnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "please enter values for all boxes"
        }
        // remove whitespace from email and password
        let cleanUsername = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        // check length of username
        if cleanUsername.count ?? 0 > 30 {
            return "username is too long"
        }
        // check if email and password are valid
        if Utilities.isValidEmail(email: cleanEmail) == false {
            return "email is not formatted correctly"
        }
        if Utilities.isValidPassword(testStr: cleanPassword) == false {
            return "invalid password, make sure password is 8 characters long and has at least 1 uppercase letter, 1 lowercase letter, and 1 digit"
        }
        
        
        return nil
    }
    func editErrorMessage (_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
        
    }
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: "tutorial") as? UIViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        // Determine if fiels are valid
        let errorValue = checkFields()
        if errorValue != nil {
            editErrorMessage(errorValue!)
        }
        // add user to firestore database
        else {
            var username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            username = String(username.filter { !" \n\t\r".contains($0) }).lowercased()
            let firstname = firstnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastname = lastnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let isPrivateAccount = accountIsPrivate.isOn
            var privateAccountVar = 0
            if(isPrivateAccount == true)  {
                privateAccountVar=1
            }
            else {
                privateAccountVar=0
            }
            // check if username aleady exists before creating account
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(username)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // username already exists
                    self.editErrorMessage("username is already taken")
                } else {
                    // create user!
                    Auth.auth().createUser(withEmail: email, password:password) { (result, err) in
                        // check if error creating user
                        if let err = err {
                            self.editErrorMessage("Error creating account")
                            print("Error creating account. \(err)")
                        }
                        else {
                            //print("Test test test")
                            //Modified this slightly to name the user document the same thing as the auth so that we can search by doc name directly instead of properties
                            // add user to users collection
                            print(username)
                            let token = Messaging.messaging().fcmToken
                            let usersRef = Firestore.firestore().collection("users").document(username)
                            db.collection("users").document(username).setData(["firstname": firstname, "lastname": lastname, "email": email, "username": username, "description": "no description","private": privateAccountVar]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(result!.user.uid)")
                                    //Grab the userID here for use everywhere else in the app
                                    Constants.User.sharedInstance.userID = username;
                                    UserDefaults.standard.setValue(result!.user.uid, forKey: "userID")
                                    UserDefaults.standard.setValue(UUID().uuidString, forKey: "sessID")
                                    usersRef.setData(["fcmToken": token], merge: true)
                                    print("reached Here")
                                    // add userID to userID collection
                                    db.collection("userids").document(result!.user.uid).setData(["username": username])
                                    db.collection("userids").document(result!.user.uid).setData(["sessionID": UserDefaults.standard.string(forKey: "sessID")!], merge: true)
                                    db.collection("users").document(username).setData(["uid": result!.user.uid], merge:true) {
                                        err in
                                        if err != nil {
                                            print("Error adding to usernames")
                                        }
                                        else {
                                            // add adminuser to contacts
                                            db.collection("users").document(username).collection("CONTACTS").document("adminuser").setData(["userRef":"adminuser"]) {
                                                err in
                                                if err != nil{
                                                    print("Error adding administrator contact: \(String(describing: err))")
                                                }
                                                else
                                                {
                                                    print("Successfully added administrator contact.")
                                                    self.transitionToHome()
                                                }
                                            }                                        }
                                    }
                                    
                                    
                                }
                            }
                            
                            // transition to home when successful
                            
                        }
                    }
                }
            }
            
        }    }
}
