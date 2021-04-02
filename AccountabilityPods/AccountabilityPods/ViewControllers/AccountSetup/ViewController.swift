//
//  ViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 10/25/20.
//  Also written by Jhada Kahan-Thomas
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseAuth
class ViewController: UIViewController {
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        tryLogin();
        // Do any additional setup after loading the view.
   
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction=UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)
    }
     struct ContentView: View {
               var body: some View {
                   Image("people")
                   .resizable()
                   .scaledToFit()
               }
           }

    func tryLogin() {
        let defaults = UserDefaults.standard
        
        let userID = defaults.string(forKey: "userID");
        let sessID = defaults.string(forKey: "sessID");
        
        if(userID == nil || sessID == nil || userID == "" || sessID == "")
        {
            return;
        }
        else
        {
            print("Made it here:");
            print(userID);
            print(sessID);
            let userIDString = userID!
            let sessionIDString = sessID!
            tryLoginFromStorage(userID: userIDString, sessID: sessionIDString);
        }
        
        
        
    }
    
    func tryLoginFromStorage(userID: String, sessID: String)
    {
        self.db.collection("userids").getDocuments() { docs, err in
        if let err = err {
            print(err)
            return;
        }
        else
        {
            for doc in docs!.documents {
                if (doc.documentID == userID)
                {
                    if((doc.data()["sessionID"]) != nil)
                    {
                        let storedID = doc.data()["sessionID"] as! String
                        if(storedID == sessID)
                        {
                        Constants.User.sharedInstance.userID = doc.data()["username"] as! String
                            let uID = UUID().uuidString
                            
                            doc.reference.setData(["sessionID": uID], merge:true);
                            UserDefaults.standard.setValue(uID, forKey: "sessID")
                        self.transitionToHome()
                        }
                        else
                        {
                            Constants.User.sharedInstance.userID = "";
                            return;
                        }
                    }
                    else
                    {
                        return;
                    }
                    
                }
            }
        }
        }
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? UITabBarController
        
           
           view.window?.rootViewController = homeViewController
           view.window?.makeKeyAndVisible()
           
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
//gradient view code
@IBDesignable class GradientView: UIView{
        var gradientLayer: CAGradientLayer {
            return layer as! CAGradientLayer
        }
        override open class var layerClass: AnyClass {
            return CAGradientLayer.classForCoder()
        }
//}
    //@IBDesignable class GradientView: UIView{
        @IBInspectable var startColor: UIColor? {
            didSet { gradientLayer.colors = cgColorGradient}
            }
        @IBInspectable var endColor: UIColor? {
            didSet { gradientLayer.colors = cgColorGradient}
        }
        @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0) {
            didSet { gradientLayer.startPoint = startPoint}
        }
        @IBInspectable var endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0) {
            didSet { gradientLayer.endPoint = endPoint}
        }
    }
    extension GradientView {
        internal var cgColorGradient: [CGColor]? {
            guard let startColor = startColor, let endColor = endColor else {
                return nil
            }
            return [startColor.cgColor, endColor.cgColor]
        }
    }

