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
    
    init(userName: String) {
        self.userName =  userName
        print("USERNAME NOTIFICATIONS \(self.userName)")
        super.init()
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
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
            print(response)
        }
    
}
