//
//  Tutorial4ViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 4/1/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit

class Tutorial4ViewController: UIViewController {

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
    
    // Closes Tutorial
    ///
    /// - Parameter sender: the done button
    @IBAction func doneTapped(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(identifier: "toHome") as? UITabBarController
        
        view.window?.rootViewController = nextViewController
        view.window?.makeKeyAndVisible()
    }
}
