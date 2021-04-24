//
//  SignUpViewController.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages the create account view controller.

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    // MARK: - UI Connectors
    
    /// The user entered username
    @IBOutlet weak var usernameTextField: UITextField!
    /// The users first name
    @IBOutlet weak var firstnameTextField: UITextField!
    /// The users last name
    @IBOutlet weak var lastnameTextField: UITextField!
    /// The user entered email
    @IBOutlet weak var emailTextField: UITextField!
    /// The user entered password
    @IBOutlet weak var passwordTextField: UITextField!
    /// The "Create your account" button
    @IBOutlet weak var createAccountButton: UIButton!
    /// The account creation error message label
    @IBOutlet weak var errorLabel: UILabel!
    /// The make account private switch button
    @IBOutlet weak var accountIsPrivate: UISwitch!
    /// The button to learn more about private accounts
    @IBOutlet weak var learnMore: UIButton!
    
    // MARK: - Set up 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // hide error message and initial private account setting to false
        setUpElements()
    }
    
    /// Hides error message label and sets private account to false
    func setUpElements() {
        errorLabel.alpha = 0 // hide error label
        self.accountIsPrivate.isOn = false
    }
    
    /// Sets keyboard to hide when screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - Validate Fields
    
    /// Check if user entered values are wellformatted.
    ///
    /// - Returns: string for error message
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
    
    /// Updates the displayed error message. 
    /// 
    /// - Parameter message: the error message to be displayed
    func editErrorMessage (_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
        
    }
    
    // MARK: - Navigation
    
    /// Transitions to tutorial page view controller when called.
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: "tutorial") as? UIViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
        
    }
        
    /// Opens pop up with information about a private account when learn more is pressed.
    ///
    /// - Parameter sender: the class of pressed object
    @IBAction func learnMoreButton_Pressed(_ sender: Any) {
        // set up pop up alert
        let alertController = UIAlertController(title: "Learn More", message: "By making your account private, no one can find or view you're profile", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        // calls the pop up
        self.present(alertController, animated: true)
    }
    
    /// Manages errors, creates account, and transitions to tutorial when account creation is successful.
    ///
    /// - Parameter sender: class of button tapped
    @IBAction func createAccountTapped(_ sender: Any) {
        // Determine if fields are valid
        let errorValue = checkFields()
        if errorValue != nil {
            editErrorMessage(errorValue!)
        }
        // add user to firestore database
        else {
            // edit the user entered information to be entered into the database
            var username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // edit username so it is lowercase and has no inner white spaces
            username = String(username.filter { !" \n\t\r".contains($0) }).lowercased()
            let firstname = firstnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastname = lastnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let isPrivateAccount = accountIsPrivate.isOn
            var privateAccountVar = 0
            // get private account information to be entered into the database
            if(isPrivateAccount == true)  {
                privateAccountVar=1
            }
            else {
                privateAccountVar=0
            }
            // check if username aleady exists before creating account
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(username)
            // try to find a document with user entered username
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
                                    // Set information in device to remember user
                                    UserDefaults.standard.setValue(result!.user.uid, forKey: "userID")
                                    UserDefaults.standard.setValue(UUID().uuidString, forKey: "sessID")
                                    // set user notication token
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
                        }
                    }
                }
            }
            
        }    }
}
