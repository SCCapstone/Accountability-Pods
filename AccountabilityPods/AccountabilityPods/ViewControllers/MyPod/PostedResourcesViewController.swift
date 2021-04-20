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
        overrideUserInterfaceStyle = .light
        self.genArray()
        self.sortResources()
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    func sortResources()
    {
        var count = 0
        while count < self.resources.count {
            var count2 = 0
            while count2 < self.resources.count
            {
                print("Checking if resource at \(count) < \(count2)")
                print("time 1: \(self.resources[count].timeStamp)")
                if self.resources[count].timeStamp > self.resources[count2].timeStamp
                {
                    print("swapping")
                    let tempMsg = self.resources[count]
                    self.resources[count] = self.resources[count2]
                    self.resources[count2] = tempMsg
                }
              count2 += 1
            }
            count += 1
        }
    }

}

extension PostedResourcesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sortResources()
        return self.resources.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("AEIOU - - - \(resources.count)")
        return 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = resources[indexPath.section]
        print("INDEXX: \(indexPath.section)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell") as! ResourceCell
        print("OWNNN: \(resource.name)")
        cell.setResource(resource: resource)
        cell.layer.cornerRadius = 15
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showOwnSegue", sender: Any?.self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

    }
    func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOwnSegue"
        {
            
            let indexPath = self.tableView.indexPathForSelectedRow
            let resource = self.resources[(indexPath?.section)!]
            if let dView = segue.destination as? OwnResourceVC {
                
                dView.resource = resource
            
            }
           
            
        }
        else
        {
            return
        }
    }
    
}
