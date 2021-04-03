//
//  Tutorial1ViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 4/1/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit

class Tutorial1ViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(identifier: "tutorial2") as? UIViewController
        
        view.window?.rootViewController = nextViewController
        view.window?.makeKeyAndVisible()
    }
    @IBAction func skipTapped(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(identifier: "toHome") as? UITabBarController
        
        view.window?.rootViewController = nextViewController
        view.window?.makeKeyAndVisible()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
