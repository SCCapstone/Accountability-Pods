//
//  Constants.swift
//  AccountabilityPods
//
//  Created by administrator on 11/27/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: accessible constants to be used in view controllers

import Foundation
import Firebase
import FirebaseFirestore

struct Constants {
    /// Struct of storyboard idenitifiers
    struct Storyboard {
        static let homeViewController = "HomeVC"
        static let startViewController = "ViewController"
    }
    /// This will let us keep the userID shared across all VCs without any extra work
    class User {
            static let sharedInstance = User()
            var userID = "";
        }
    
    /// reference for chat data
    struct chatRefs
    {
        // location of chats
        static let databaseRoot = Firestore.firestore()
        static let databaseChats = databaseRoot.collection("Chats")
    }
}
