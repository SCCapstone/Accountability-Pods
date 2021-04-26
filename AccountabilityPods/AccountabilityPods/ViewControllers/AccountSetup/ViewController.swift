//
//  ViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 10/25/20.
//  Also written by Jhada Kahan-Thomas
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages view controller that shows when app is first open.

import UIKit
import SwiftUI
import Firebase
import FirebaseAuth
class ViewController: UIViewController {
    // MARK: - Class Variables
    
    ///  The Firesetore database
    let db = Firestore.firestore()
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tryLogin();
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction=UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)
    }
    
    /// struct for images on page
    struct ContentView: View {
               var body: some View {
                   Image("people")
                   .resizable()
                   .scaledToFit()
               }
           }
    
    // MARK: - Navigation
    
    /// Logs in user when device has stored signing in values and
    /// calls tryLoginFromStorage() with stored information
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
            let userIDString = userID!
            let sessionIDString = sessID!
            tryLoginFromStorage(userID: userIDString, sessID: sessionIDString);
        }
        
    }
    
    /// Finishes logging in user and updates database with device information
    ///
    /// - Parameters:
    ///   - userID: user id number stored in device
    ///   - sessID: session information stored in device
    func tryLoginFromStorage(userID: String, sessID: String)
    {
        // gets collection of user ids
        self.db.collection("userids").getDocuments() { docs, err in
        if let err = err {
            print(err)
            return;
        }
        else
        {
            for doc in docs!.documents {
                // gets doc that matches id stored in device
                if (doc.documentID == userID)
                {
                    if((doc.data()["sessionID"]) != nil)
                    {
                        let storedID = doc.data()["sessionID"] as! String
                        if(storedID == sessID)
                        {
                            // sets user information shared with other view controllers
                        Constants.User.sharedInstance.userID = doc.data()["username"] as! String
                            let uID = UUID().uuidString
                            
                            doc.reference.setData(["sessionID": uID], merge:true);
                            UserDefaults.standard.setValue(uID, forKey: "sessID")
                            // user logged in and enters home page
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
    
    /// Transitions to home page view controller when called.
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? UITabBarController
           view.window?.rootViewController = homeViewController
           view.window?.makeKeyAndVisible()
           
    }
}
extension UIViewController
{
    /// Manages swipes on page
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
// MARK: - Design elements of view controller.

/// Designs the gradient
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

