//
//  HomeViewController.swift
//  AccountabilityPods
//
// Created by Duncan Evans on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages the outer part of the HOME view

import UIKit
import Firebase
class HomeViewController: UIViewController {
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // page only works with light mode
        overrideUserInterfaceStyle = .light
    }
    
    /// hides keyboard when somewhere else on screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Button functionality
    
    /// Signs out user when logout is tapped
    @IBAction func onSignOutTapped(_ sender: Any) {
        // alert user to ask again if they wanna sign out
        let alertController = UIAlertController(title: "Sign Out", message: "Would you like to sign out?", preferredStyle: .alert)
        // logout user when they press year
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
                do {
                    // change ftm token to remove notifications
                    let db = Firestore.firestore()
                    db.collection("users").document(Constants.User.sharedInstance.userID).updateData([
                                   "fcmToken": ""
                    ]) { err in
                        if let err = err {
                            print("Error updating token on logout : \(err)")
                        } else {
                            print("FCM token updated on logout")
                        }
                    }
                    self.dismiss(animated:true, completion: {
                    UserDefaults.standard.setValue("", forKey: "userID")
                    UserDefaults.standard.setValue("", forKey: "sessID")
                    Constants.User.sharedInstance.userID = "";
                    
                    let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.startViewController)
                    
                    // change view controller
                    self.view.window?.rootViewController = homeViewController
                    self.view.window?.makeKeyAndVisible()
                        
                    
                })
                //try Auth.auth().signOut()
                } catch {
                print(error)
                }
            }))
        alertController.addAction(UIAlertAction(title:"No", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    
    /// Gives user information about what is on the screen
    @IBAction func helpTapped(_ sender: Any) {
        // create and present alert controller
        let alertController = UIAlertController(title: "Home Help", message: "Click + to make a post, scroll through other posts, tap on resources to see more, or logout by tapping left hand corner\n Watch tutorial from settings for more detail!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
}


