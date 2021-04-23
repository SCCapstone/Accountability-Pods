//
//  ForgotPasswordViewController.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages forgot password page view controller

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    // MARK: - UI Connectors
    
    /// The outlet to the user entered email
    @IBOutlet weak var emailTextField: UITextField!
    /// The outlet to the "Send Reset!" button
    @IBOutlet weak var sendButton: UIButton!
    /// The outlet to the error message label
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // clear error label
        self.errorLabel.text = ""
    }
    
    /// Sets keyboard to hide when screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // tapping hides keyboard
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    
    /// Sends email or changes error label once "Send Reset!" has been pressed
    ///
    /// - Parameter _sender: The class of the button causing action
    @IBAction func forgotPasswordButton_Tapped(_ sender: UIButton) {
        // Uses firebase authentication to send password reset to valid email
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
            if error == nil {
                print("SENT...!")
                // Sends alert to user saying that an email has been sent
                let alertController = UIAlertController(title: "Password Reset", message: "Check your email!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) {
                    (action) -> Void in
                    let LogInviewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(LogInviewController!, animated: true, completion: nil)
                  }
                  alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // invalid email has been entered, error label altered
                print("FAILED -\(String(describing: error?.localizedDescription))")
                self.errorLabel.text = "Enter valid email"
            }
        }
    }
}
