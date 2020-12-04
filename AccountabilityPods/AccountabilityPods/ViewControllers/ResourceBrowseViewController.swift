//
//  ResourceBrowseViewController.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class ResourceBrowseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var resources: [Resource] = []
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        genArray()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        print("Test")
        
    }
    
    func genArray(){
        let usersRef = db.collection("users")
        let currUserRef = usersRef.document(Constants.User.sharedInstance.userID)
        let userContactRef = currUserRef.collection("CONTACTS")
        
        userContactRef.getDocuments() {
            docsSnap, error in
            if let error = error {
                print("Error getting contacts. \(error)")
            }
            else
            {
                if(self.resources.count == 10)
                {
                    //print("Somehow I triggered this!")
                    return
                }
                for doc in docsSnap!.documents {
                    let d = doc.get("userRef") as! String
                    let tempUserRef = usersRef.document(d)
                    let userResourceRef = tempUserRef.collection("POSTEDRESOURCES")
                    //print("\n\n\n\n\n\nHere is the thing: \(d) \n\n\n\n")
                    userResourceRef.getDocuments()
                    {
                        
                        resourceSnaps, error2 in
                        if let error = error2 {
                            print("Error getting contact resources. \(error)")
                        }
                        else
                        {
                            //print("We got in here fine.")
                            //print(resourceSnaps?.count)
                            //print(resourceSnaps?.documents)
                            for doc in resourceSnaps!.documents {
                                let path = doc.reference.path
                                print("AEIOU")
                                var newResource = Resource(base: self.db, path_:path)
                                newResource.readData(database: self.db, path: path, tableview: self.tableView)
                                
                                print(newResource.name)
                                
                                self.resources.append(newResource)
                                for item in self.resources {
                                    print(item)
                                    print(item.name)
                                    print(item.desc)
                                    self.tableView.reloadData()
                                }
                                if(self.resources.count >= 10)
                                {
                                    return
                                }
                                
                                
                            }
                        }
                        
                    }
                }
            }
            
        }
        
    }
    
}
extension ResourceBrowseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = resources[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell") as! ResourceCell
        
        cell.setResource(resource: resource)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showResourceSegue", sender: Any?.self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResourceSegue"
        {
            let indexPath = self.tableView.indexPathForSelectedRow
            let resource = self.resources[(indexPath?.row)!]
            if let dView = segue.destination as? ResourceDisplayVC {
                dView.resource = resource
            }
           
            
        }
        else
        {
            return
        }
    }
    
}
