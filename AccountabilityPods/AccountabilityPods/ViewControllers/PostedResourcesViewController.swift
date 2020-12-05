//
//  PostedResourcesViewController.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class PostedResourcesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let db = Firestore.firestore()
    
    var resources: [Resource] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.genArray()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "OnEditResource"), object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func reload()
    {
        print("Notified")
        self.resources = []
        print("Resources cleared: \(resources)")
        genArray()
        tableView.reloadData()
        
    }

    func genArray(){
        self.resources = []
        
        let usersRef = db.collection("users")
        let currUserRef = usersRef.document(Constants.User.sharedInstance.userID)
        let savedResourceRef = currUserRef.collection("POSTEDRESOURCES")
        print("Here")
        savedResourceRef.getDocuments() {
            docsSnap, error in
            if let error = error {
                print("Error getting posted resources. \(error)")
            }
            else
            {
                print("Debugging here")
                for doc in docsSnap!.documents {
                    let path = doc.reference.path
                    print("\n\n\n\n\n" + path + "\n\n\n\n\n")
                    let newResource = Resource(base: self.db, path_:path)
                    newResource.readData(database: self.db, path: path, tableview: self.tableView)
                                
                                //print(newResource.name)
                                
                    self.resources.append(newResource)
                    self.tableView.reloadData()
                                
                                
                                
                            }
                        }
                        
                    }
                
            
            
        
        
    }

}

extension PostedResourcesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("AEIOU - - - \(resources.count)")
        return resources.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = resources[indexPath.row]
        print(resource)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell") as! ResourceCell
        print(resource.name)
        cell.setResource(resource: resource)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showOwnSegue", sender: Any?.self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOwnSegue"
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
