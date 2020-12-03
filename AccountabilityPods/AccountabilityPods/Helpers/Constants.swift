//
//  Constants.swift
//  AccountabilityPods
//
//  Created by administrator on 11/27/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import Foundation

struct Constants {
    struct Storyboard {
        static let homeViewController = "HomeVC"
    }
    //This will let us keep the userID shared across all VCs without any extra work
    class User {
            static let sharedInstance = User()
            var userID = "";
        }
}
