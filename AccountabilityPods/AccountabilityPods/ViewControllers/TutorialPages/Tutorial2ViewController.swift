//
//  Tutorial2ViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 4/1/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//
//  Description: Manages second tutorial page
import UIKit

class Tutorial2ViewController: UIViewController {

    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // page only works with light mode
        overrideUserInterfaceStyle = .light
    }
    
    /// Hides keyboard when user taps on other part of screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    /// Goes to next tutorial page
    ///
    /// - Parameter sender: the next button
    @IBAction func nextTapped(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(identifier: "tutorial3")
        
        view.window?.rootViewController = nextViewController
        view.window?.makeKeyAndVisible()
    }
    
    /// Closes Tutorial
    ///
    /// - Parameter sender: the skip button
    @IBAction func skipTapped(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(identifier: "toHome") as? UITabBarController
        
        view.window?.rootViewController = nextViewController
        view.window?.makeKeyAndVisible()
    }
}
