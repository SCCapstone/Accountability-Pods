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
    public var timeStamp: Int64
    public var path: String
    
    public var hashableResource: ResourceHashable
    //var doc: DocumentSnapshot
    
    init()
    {
        self.path = ""
        self.name = "No name"
        self.desc = "No desc"
        self.timeStamp = 0
        self.hashableResource = ResourceHashable(name:self.name,desc:self.desc,path:self.path)
    }
    init(base: Firestore, path_: String)
    {
        self.path = ""
        self.name = "No name"
        self.desc = "No desc"
        self.timeStamp = 0
        self.hashableResource = ResourceHashable(name:self.name,desc:self.desc,path:self.path)
        readData(database: base,path: path_)
        
        
    }
    init(name: String, desc: String, path: String)
    {
        self.path = path
        self.name = name
        self.desc = desc
        self.timeStamp = 0
        self.hashableResource = ResourceHashable(name:self.name,desc:self.desc,path:self.path)
    }
    
    func readData(database: Firestore, path: String)
    {
        
        self.path = path
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            let data = querySnapshot!.data()
            
            if(data?["resourceName"] == nil || data?["resourceDesc"] == nil )
            {
                return
            }
            
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
            if(data?["resourceName"] == nil || data?["resourceDesc"] == nil || path == nil)
            {
                return
            }
            let name_ = data!["resourceName"] as! String
            let desc_ = data!["resourceDesc"] as! String
            self.name = name_
            self.desc = desc_
            if(data?["time"] != nil){
                let time_ = data!["time"] as! Int64
                self.timeStamp = time_
            }
            
            tableview.reloadData()
            
            
        }
    }
    func readData(database: Firestore, path: String, collectionview: UICollectionView)
    {
        
        
        self.path = path
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            let data = querySnapshot!.data()
            if(data?["resourceName"] == nil || data?["resourceDesc"] == nil || path == nil )
            {
                return
            }
            let name_ = data!["resourceName"] as! String
            let desc_ = data!["resourceDesc"] as! String
            
            self.name = name_
            self.desc = desc_
            self.hashableResource = ResourceHashable(name:name_,desc:desc_,path:path)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ResourceAsyncFinished"), object: nil)
            
            print(self.hashableResource.name + "actual name here")
            
            
        }
    }
    func makeHashableStruct() -> ResourceHashable!
    {
        
        let resourceHashable = ResourceHashable(name: self.name,desc: self.desc,path: self.path);
        return resourceHashable;
    }
    
  

}

// Hashable struct of a resource, primarily used for collections. Same will exist for contacts
//Important note: If you have to use this, I recommend reconstructing a hash rather than making a copy unless you are careful. Having two+ of the same instance will more likely than not cause a crash due to not being able to resolve the hash to a unique object.
struct ResourceHashable: Hashable {
    let uuid = UUID()
    let name: String
    let desc: String
    let path: String
}
class Skill {
    public var name: String
    public var desc: String
    
    public var path: String
    //var doc: DocumentSnapshot
    
    init()
    {
        self.path = ""
        self.name = "No name"
        self.desc = "No desc"
    }
    init(base: Firestore, path_: String)
    {
        self.path = ""
        self.name = "No name"
        self.desc = "No desc"
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
            
            if(data?["skillName"] == nil || data?["skillDescription"] == nil )
            {
                return
            }
            
            let name_ = data!["skillName"] as! String
            let desc_ = data!["skillDescription"] as! String
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
            if(data?["skillName"] == nil || data?["skillDescription"] == nil || path == nil )
            {
                return
            }
            let name_ = data!["skillName"] as! String
            let desc_ = data!["skillDescription"] as! String
            
            self.name = name_
            self.desc = desc_
            tableview.reloadData()
            
            
        }
}
}

class Profile {
    public var firstName: String
    public var lastName: String
    public var description: String
    public var uid: String
    public var path: String
    
    //Note: Profile originally had both uid and username.
    //      This has since been changed as there is no longer a reason for the alphanumeric userid to be stored. However, to prevent a large number of changes it made more sense to just condense the two into the uid variable.
    
    public var hashableProfile: ProfileHashable
    
    
    init() {
        self.path = ""
        self.firstName = "No name"
        self.lastName = "No name"
        self.description = ""
        self.uid = ""
        self.hashableProfile = ProfileHashable()
        
    }
    
    init(base: Firestore, path_:String) {
        self.path = ""
        self.firstName = "No name"
        self.lastName = "No name"
        self.description = ""
        self.uid = ""
        self.hashableProfile = ProfileHashable()
        readData(database: base, path: path_)
    }
    
    func readData(database: Firestore, path: String) {
        self.path = path
        
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            let data = querySnapshot!.data()
            if (data?["username"] == nil || data?["firstname"] == nil || data?["lastname"] == nil || data?["uid"] == nil){
                return
            }
            
            let first_ = data!["firstname"] as! String
            let last_ = data!["lastname"] as! String
            let user_ = data!["username"] as! String
            var des_ = ""
            if (data?["description"] != nil) {
                des_ = data!["description"] as! String
            }
            
            self.firstName = first_
            self.lastName = last_
            
            self.description = des_
            self.uid = user_
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProfileAsyncFinished"), object: nil)
        }
    }
    
    func readData(database: Firestore, path: String, tableview: UITableView) {
        self.path = path
        
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            let data = querySnapshot!.data()
            //print("\(data)")
            
            if (data?["username"] == nil || data?["firstname"] == nil || data?["lastname"] == nil) {
                return
            }
            let first_ = data!["firstname"] as! String
            let last_ = data!["lastname"] as! String
            let user_ = data!["username"] as! String
            var des_ = ""
            if (data?["description"] != nil) {
                des_ = data!["description"] as! String
            }
            
            self.firstName = first_
            self.lastName = last_
            self.uid = user_
            self.description = des_
            //self.uid = uid_
            //print(self.userName)
            tableview.reloadData()
        }
    }
    func readData(database: Firestore, path: String, collectionview: UICollectionView) {
        self.path = path
        
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            let data = querySnapshot!.data()
            //print("\(data)")
            
            if (data?["username"] == nil || data?["firstname"] == nil || data?["lastname"] == nil) {
                return
            }
            let first_ = data!["firstname"] as! String
            let last_ = data!["lastname"] as! String
            let user_ = data!["username"] as! String
            var des_ = ""
            if (data?["description"] != nil) {
                des_ = data!["description"] as! String
            }
            
            self.firstName = first_
            self.lastName = last_
            self.uid = user_
            self.description = des_
            
        
            //self.uid = uid_
            //print(self.userName)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProfileAsyncFinished"), object: nil)
            collectionview.reloadData()
        }
    }
    func hash()
    {
        self.hashableProfile = ProfileHashable(first:self.firstName,last:self.lastName,desc: self.description,path:self.path,uid:self.uid)
    }
    
    
    func readFromResourcePath(database: Firestore, path: String)
    {
        let directories = path.split(separator: "/")
        
        let pathTemp: String
        pathTemp = directories[0] + "/" + directories[1]
        
        self.readData(database: database, path: pathTemp)
    }
    
    func unHash(hashProfile: ProfileHashable)
    {
        self.firstName = hashProfile.firstName
        self.lastName = hashProfile.lastName
        self.uid = hashProfile.uid
        self.description = hashProfile.description
    }
}

public struct ProfileHashable: Hashable {
    let firstName: String
    let lastName: String
    let uid: String
    let description: String
    let path: String
    let uniqueID = UUID()
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.description = ""
        self.path = ""
        self.uid = ""
    }
    init(first: String, last: String, desc: String, path: String, uid: String)
    {
        self.firstName = first
        self.lastName = last
        self.description = desc
        self.path = path
        self.uid = uid
    }
}
