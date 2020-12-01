//
//  ViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 10/25/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
   
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction=UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)
    }


}
extension UIViewController
{
    @objc func swipeAction(swipe:UISwipeGestureRecognizer)
    {
        switch swipe.direction.rawValue {
      case 1:
            performSegue(withIdentifier: "goLeft", sender: self)
        case 2:
            performSegue(withIdentifier: "goRight", sender: self)
        default:
            break
        }
    }
}

