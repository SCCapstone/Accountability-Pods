//
//  Utilities.swift
//  AccountabilityPods
//
//  Created by administrator on 11/26/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: contains helpful static functions and object classes

import Foundation
import UIKit
import Firebase

class Utilities {
    
    // MARK: - Validation Functions
    
   
    
    /// Returns whether given email is in correct format
    ///
    /// - Parameter email: the email to be tested
    /// - Returns: true or false if email is well formatted
    static func isValidEmail(email:String?) -> Bool {
        
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    /// Returns whether given password is wellformatted
    ///
    /// - Parameter testStr: the password to be tested
    /// - Returns: true or false if password  is well formatted
    static func isValidPassword(testStr:String?) -> Bool {
        guard testStr != nil else { return false }
     
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: testStr)
    }
    
    /* validate that email and password are in right format
     from http://brainwashinc.com/2017/08/18/ios-swift-3-validate-email-password-format/
    */
    
   
}

// MARK: - Resource Classes

/// Class for resource object used to populate table views
class Resource {
    /// display name of the resource
    public var name: String
    /// description of the resource
    public var desc: String
    /// time in database that resource was created
    public var timeStamp: Int64
    /// path to the resource in the database
    public var path: String
    
    /// resource object that is hashable for collection views
    public var hashableResource: ResourceHashable
    //var doc: DocumentSnapshot
    
    /// Sets variables to default values
    init()
    {
        self.path = ""
        self.name = "No name"
        self.desc = "No desc"
        self.timeStamp = 0
        self.hashableResource = ResourceHashable(name:self.name,desc:self.desc,path:self.path)
    }
    
    /// Take paths and database and  set variables with data from the database with read data function
    ///
    /// - Parameters:
    ///   - base: the database with the resource
    ///   - path_: the given path to be assigned to the object
    init(base: Firestore, path_: String)
    {
        self.path = ""
        self.name = "No name"
        self.desc = "No desc"
        self.timeStamp = 0
        self.hashableResource = ResourceHashable(name:self.name,desc:self.desc,path:self.path)
        readData(database: base,path: path_)
        
        
    }
    
    /// Sets variables to given information
    ///
    /// - Parameters:
    ///   - name: display name
    ///   - desc: resouce description
    ///   - path: path to resource
    init(name: String, desc: String, path: String)
    {
        self.path = path
        self.name = name
        self.desc = desc
        self.timeStamp = 0
        self.hashableResource = ResourceHashable(name:self.name,desc:self.desc,path:self.path)
    }
    
    /// Sets variables from information in database
    ///
    /// - Parameters:
    ///   - database: the database with the resource
    ///   - path: the given path to be assigned to the object
    func readData(database: Firestore, path: String)
    {
        
        self.path = path
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            if( querySnapshot?.data() != nil)
            {
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
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ResourceDoesNotExist"), object: self)
            }
        
        }
        
       
    
    }
    /// Sets variables from information in database and reloads the table view
    ///
    /// - Parameters:
    ///   - database: the database with the resource
    ///   - path: the given path to be assigned to the object
    ///   - tableview: the table the resource is being added to
    func readData(database: Firestore, path: String, tableview: UITableView)
    {
        
        
        self.path = path
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            if( querySnapshot?.data() != nil) {
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
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ResourceDoesNotExist"), object: self)
            }
        }
    }
    /// Sets variables from information in database and reloads the collection view
    ///
    /// - Parameters:
    ///   - database: the database with the resource
    ///   - path: the given path to be assigned to the object
    ///   - collectionview: the collection the resource is being added to
    func readData(database: Firestore, path: String, collectionview: UICollectionView)
    {
        
        
        self.path = path
        database.document(path).addSnapshotListener {
            (querySnapshot, error) in
            if( querySnapshot?.data() != nil) {
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
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ResourceDoesNotExist"), object: self)
            }
            
        }
    }
    /// Makes the resource object into a hashable resource object for collection view
    ///
    /// - Returns: a hashable resource
    func makeHashableStruct() -> ResourceHashable!
    {
        
        let resourceHashable = ResourceHashable(name: self.name,desc: self.desc,path: self.path);
        return resourceHashable;
    }
    
  

}

/// Hashable struct of a resource, primarily used for collections. Same will exist for contacts
//Important note: If you have to use this, I recommend reconstructing a hash rather than making a copy unless you are careful. Having two+ of the same instance will more likely than not cause a crash due to not being able to resolve the hash to a unique object.
struct ResourceHashable: Hashable {
    let uuid = UUID()
    let name: String
    let desc: String
    let path: String
}

// MARK: - Skill Class
class Skill {
    /// display name of skill
    public var name: String
    /// display name of description
    public var desc: String
    /// the path to the skill in the database
    public var path: String
    
    /// Sets variables to default values
    init()
    {
        self.path = ""
        self.name = "No name"
        self.desc = "No desc"
    }
    
    /// Take paths and database and  set variables with data from the database with read data function
    ///
    /// - Parameters:
    ///   - base: the database with the skill
    ///   - path_: the given path to be assigned to the object
    init(base: Firestore, path_: String)
    {
        self.path = ""
        self.name = "No name"
        self.desc = "No desc"
        readData(database: base,path: path_)
        
        
    }
    
    /// Sets variables to given information
    ///
    /// - Parameters:
    ///   - name: display name
    ///   - desc: skill description
    ///   - path: path to resource
    init(name: String, desc: String, path: String)
    {
        self.path = path
        self.name = name
        self.desc = desc
    }
    
    /// Sets variables from information in database
    ///
    /// - Parameters:
    ///   - database: the database with the resource
    ///   - path: the given path to be assigned to the object
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
    
    /// Sets variables from information in database and reloads the table view
    ///
    /// - Parameters:
    ///   - database: the database with the resource
    ///   - path: the given path to be assigned to the object
    ///   - tableview: the table the resource is being added to
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

// MARK: - Profile classes

/// Class for profile object, a user that is not the current user,  used to populate table and collection views
class Profile {
    /// user's first name
    public var firstName: String
    /// user's last name
    public var lastName: String
    /// user's profile decription
    public var description: String
    /// user's username
    public var uid: String
    /// path to user in database
    public var path: String
    
    //Note: Profile originally had both uid and username.
    //      This has since been changed as there is no longer a reason for the alphanumeric userid to be stored. However, to prevent a large number of changes it made more sense to just condense the two into the uid variable.
    /// profile object that is hashable for collection views
    public var hashableProfile: ProfileHashable
    
    /// Sets variables to default values
    init() {
        self.path = ""
        self.firstName = "No name"
        self.lastName = "No name"
        self.description = ""
        self.uid = ""
        self.hashableProfile = ProfileHashable()
        
    }
    
    /// Take paths and database and  set variables with data from the database with read data function
    ///
    /// - Parameters:
    ///   - base: the database with the profile
    ///   - path_: the given path to be assigned to the object
    init(base: Firestore, path_:String) {
        self.path = ""
        self.firstName = "No name"
        self.lastName = "No name"
        self.description = ""
        self.uid = ""
        self.hashableProfile = ProfileHashable()
        readData(database: base, path: path_)
    }
    
    /// Sets variables from information in database
    ///
    /// - Parameters:
    ///   - database: the database with the profile
    ///   - path: the given path to be assigned to the object
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
    
    /// Sets variables from information in database and reloads the table view
    ///
    /// - Parameters:
    ///   - database: the database with the profile
    ///   - path: the given path to be assigned to the object
    ///   - tableview: the table the profile  is being added to
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
    
    /// Sets variables from information in database and reloads the collection view
    ///
    /// - Parameters:
    ///   - database: the database with the profile
    ///   - path: the given path to be assigned to the object
    ///   - collectionview: the collection the profile is being added to
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
    /// Makes the profile object into a hashable profile object for collection view
    ///
    /// - Returns: a hashable profile
    func hash()
    {
        self.hashableProfile = ProfileHashable(first:self.firstName,last:self.lastName,desc: self.description,path:self.path,uid:self.uid)
    }
    
    /// Set variables for user who posted a resource from a given resource path
    ///
    /// - Parameters:
    ///   - database: the firestore database
    ///   - path: the path to the resource that the user posted
    func readFromResourcePath(database: Firestore, path: String)
    {
        // get user path by cutting the resource path
        let directories = path.split(separator: "/")
        
        let pathTemp: String
        pathTemp = directories[0] + "/" + directories[1]
        
        self.readData(database: database, path: pathTemp)
    }
    
    /// Set unhashed profile to information from a hashed profile
    ///
    /// - Parameter hashProfile: a profile that has been made hashable
    func unHash(hashProfile: ProfileHashable)
    {
        self.firstName = hashProfile.firstName
        self.lastName = hashProfile.lastName
        self.uid = hashProfile.uid
        self.description = hashProfile.description
    }
}

/// Hashable struct of a profile
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
