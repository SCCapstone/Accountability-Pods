//
//  Constants.swift
//  AccountabilityPods
//
//  Created by administrator on 11/27/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Constants {
    struct Storyboard {
        static let homeViewController = "HomeVC"
        static let startViewController = "ViewController"
    }
    //This will let us keep the userID shared across all VCs without any extra work
    class User {
            static let sharedInstance = User()
            var userID = "";
        }
    
    //reference for chat data
    struct chatRefs
    {
        static let databaseRoot = Firestore.firestore()
        //is t stored in storage? Storage.storage().reference()
        //firebase.storage().ref()
        static let databaseChats = databaseRoot.collection("Chat")
    }
}
