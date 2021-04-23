//
//  LoginViewController.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages login page view controller

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - UI Connectors
   
    /// The user entered email
    @IBOutlet weak var emailTextField: UITextField!
    /// The user enter password
    @IBOutlet weak var passwordTextField: UITextField!
    /// The "Enter your Power Pod!" button
    @IBOutlet weak var enterButton: UIButton!
    /// The error message label
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Class Variables
    
    ///  The Firesetore database
    let db = Firestore.firestore()
   
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // configure right swipe gesture
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction=UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
        // set up the UI elements
        setUpElements()
    }
    
    /// Sets up the error label when page is first opened.
    func setUpElements() {
        errorLabel.alpha = 0 // hide error label
    }
    
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: Textfield Validation Methods.
   
    /// Checks if user entered values for password and email
    ///
    /// - Returns: error message if fields are empty
    func checkFields() -> String? {
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "please enter values for all boxes"
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
   
    /// Updates notification token field in database if user logs in from a new device. 
    /// 
    /// Parameter username: the user generated unique username of user logging in
    func checkTokenChanged(username: String) {
        // gets document for user logging in
        let usersRef = db.collection("users").document(username)
        usersRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                print("DOCUMENT FOUND \(document.data())")
                // users notification token from current device
                let newtoken = Messaging.messaging().fcmToken
                // users notification token in database
                let currToken = document.get("fcmToken") as? String
                // checks if both tokens are the same
                if(currToken == newtoken) {
                    print("USER USES SAME TOKEN \(currToken ?? "new token")")
                    return
                }
                else {
                    // updates token in database if user is on a new device
                    print("USER is on different device replacing token to updated token")
                    usersRef.setData(["fcmToken": newtoken], merge: true)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    /// Transitions to home page view controller when called.
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? UITabBarController
           view.window?.rootViewController = homeViewController
           view.window?.makeKeyAndVisible()
           
    }
   
    /// Logs in user or provides error message when "Enter your Pod!" is tapped.
    ///
    /// - Parameter sender: the class for the tapped item
    @IBAction func enterTapped(_ sender: Any) {
        // check if text fields are empty
        let errorValue = checkFields()
        if errorValue != nil {
            editErrorMessage(errorValue!)
        }
        // sign in user with given information
        else {
            // remove whitespace from text fields
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // use firebase authentication to sign in user
            Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
                if error != nil {
                    // error signing in user, updates error message label
                    self.editErrorMessage(error!.localizedDescription)
                }
                else {
                    // gets list of all userids
                    self.db.collection("userids").getDocuments() { docs, err in
                    if let err = err {
                        print(err)
                    }
                    else
                    {
                        for doc in docs!.documents {
                            // Check for document for current user
                            if (doc.documentID == result!.user.uid)
                            {
                                print("Successfully got the username from ID!")
                                // set shared instance of user name to be used by other view controllers
                                Constants.User.sharedInstance.userID = doc.data()["username"] as! String
                                // check and update push notifcation token
                                self.checkTokenChanged(username: doc.data()["username"] as! String)
                                // set user defaults for device so user does not need to sign in everytime
                                UserDefaults.standard.setValue(doc.documentID, forKey: "userID")
                                UserDefaults.standard.setValue(UUID().uuidString, forKey: "sessID")
                                // update database to have session ID
                                self.db.collection("userids").document(result!.user.uid).setData(["sessionID": UserDefaults.standard.string(forKey: "sessID")!], merge:true)
                                // finish logging in, transition UI to home page
                                self.transitionToHome()
                            }
                        }
                        print("Error getting username from ID.")
                    }
               }
            }
        }    
        }
    }
}

