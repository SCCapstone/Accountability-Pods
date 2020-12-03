//
//  MessagingViewController.swift
//  AccountabilityPods
//
//  Created by SCHOLZ, JENNIFER T on 12/2/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class MessagingViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        setUpElements()
    }
    func setUpElements() {
        errorLabel.alpha = 0 // hide error label
    }

}
