//
//  HomeViewController.swift
//  AccountabilityPods
//
// Created by Duncan Evans on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        

        // Do any additional setup after loading the view.
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
    @IBAction func onSignOutTapped(_ sender: Any) {
        do {
            
            self.dismiss(animated:true, completion: {
                
                //performSegue(withIdentifier: "signOutSegue", sender: nil)
                UserDefaults.standard.setValue("", forKey: "userID")
                UserDefaults.standard.setValue("", forKey: "sessID")
                Constants.User.sharedInstance.userID = "";
                
                let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.startViewController)
                
                   
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
                
                
            })
            //try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func helpTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Home Help", message: "Click + to make a post, scroll through other posts, tap on resources to see more, or logout by tapping left hand corner\n Watch tutorial from settings for more detail!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
}


