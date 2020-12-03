//
//  Utilities.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Utilities {
    /* validate that email and password are in right format
     from http://brainwashinc.com/2017/08/18/ios-swift-3-validate-email-password-format/
    */
    static func isValidEmail(email:String?) -> Bool {
        
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    static func isValidPassword(testStr:String?) -> Bool {
        guard testStr != nil else { return false }
     
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: testStr)
    }
    
   
}

class Resource {
    public var name: String
    public var desc: String
    
    public var path: String
    //var doc: DocumentSnapshot
    
    init(base: Firestore, path_: String)
    {
        self.path = path_
        self.name = "This is blank"
        self.desc = ""
        readData(database: base,path: path_)
        
        
    }
    init(name: String, desc: String, path: String)
    {
        self.path = path
        self.name = name
        self.desc = desc
    }
    
    func readData(database: Firestore, path: String)
    {
        
        self.path = path
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            let data = querySnapshot!.data()
            let name_ = data!["resourceName"] as! String
            let desc_ = data!["resourceDesc"] as! String
            self.name = name_
            self.desc = desc_
            
            
        }
        
       
    
    }
    func readData(database: Firestore, path: String, tableview: UITableView)
    {
        
        self.path = path
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            let data = querySnapshot!.data()
            let name_ = data!["resourceName"] as! String
            let desc_ = data!["resourceDesc"] as! String
            self.name = name_
            self.desc = desc_
            tableview.reloadData()
            
            
        }
    }
}

