//
//  ForgotPasswordViewController.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
          self.errorLabel.text = ""
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func sendTapped(_ sender: Any) {
    }
   /*
    @IBAction func showAlert(_ sender: Any) {
        let alertController = UIAlertController(title: "Password Reset", message: "Check your email!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController,animated: true, completion: nil)
    }*/
    @IBAction func forgotPasswordButton_Tapped(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
            if error == nil {
                print("SENT...!")
                let alertController = UIAlertController(title: "Password Reset", message: "Check your email!", preferredStyle: .alert)
                       alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                       self.present(alertController,animated: true, completion: nil)
            } else {
                print("FAILED -\(String(describing: error?.localizedDescription))")
                self.errorLabel.text = "Enter valid email"
            }
        }
    }
}
