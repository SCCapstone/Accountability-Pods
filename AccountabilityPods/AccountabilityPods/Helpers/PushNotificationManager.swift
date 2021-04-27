//
//  PushNotificationManager.swift
//  AccountabilityPods
//
//  Created by KAHAN-THOMAS, JHADA L on 4/1/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    //var userN: String
    let userName: String
    var window: UIWindow?
    var notifsEnabled: Bool = true
    init(userName: String) {
        self.userName =  userName
        print("USERNAME NOTIFICATIONS \(self.userName)")
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.disable), name: NSNotification.Name(rawValue: "DisableVisibleNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enable), name: NSNotification.Name(rawValue: "EnableVisibleNotif"), object: nil)
        
    }
    
    @objc func disable() {
        self.notifsEnabled = false
    }
    @objc func enable() {
        self.notifsEnabled = true
    }
        
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
                // For iOS 10 data message (sent via FCM)
        Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
            }
            UIApplication.shared.registerForRemoteNotifications()
            updateFirestorePushTokenIfNeeded()
    }
    
    func updateFirestorePushTokenIfNeeded() {
        print("I am coming to update")
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users").document(userName)
            usersRef.setData(["fcmToken": token], merge: true)
            }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
            //print(remoteMessage.appData)
            print("is getting message data")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            updateFirestorePushTokenIfNeeded()
    }
    
    //in app messaging notifcation
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //let topMostViewController = UIApplication.shared.topMostViewController()
        if !self.notifsEnabled{
            completionHandler([])
        } else{
            completionHandler([.alert, .badge, .sound])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
        let storyboard = UIStoryboard(name: "Messages", bundle: nil)
        if let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController, let navController = self.window?.rootViewController as? UINavigationController {
            navController.pushViewController(chatVC, animated: true)
        }
            print(response)
        }
    
}

extension UIViewController {
    var topViewController: UIViewController? {
        return self.topViewController(currentViewController: self)
    }

    private func topViewController(currentViewController: UIViewController) -> UIViewController {
        if let tabBarController = currentViewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self.topViewController(currentViewController: selectedViewController)
        } else if let navigationController = currentViewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return self.topViewController(currentViewController: visibleViewController)
       } else if let presentedViewController = currentViewController.presentedViewController {
            return self.topViewController(currentViewController: presentedViewController)
       } else {
            return currentViewController
        }
    }
}
/*extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
            
        if let tab = self as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow }.first?.rootViewController?.topMostViewController()
    }
}*/
