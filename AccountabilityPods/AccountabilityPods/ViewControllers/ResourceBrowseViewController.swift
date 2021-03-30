//
//  ResourceBrowseViewController.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/3/20.
//  May be removed in the near future
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class ResourceBrowseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var resources: [Resource] = []
    let db = Firestore.firestore()
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.genArray), name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
       
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        genArray()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        print("Test: Loading Resources")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func genArray(){
        self.resources = []
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
                               // print("AEIOU")
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.resources.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = resources[indexPath.section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell") as! ResourceCell
        
        cell.setResource(resource: resource)
        cell.layer.cornerRadius = 15
        return cell
        
    }
    func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showResourceSegue", sender: Any?.self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResourceSegue"
        {
            let indexPath = self.tableView.indexPathForSelectedRow
            let resource = self.resources[(indexPath?.section)!]
            if let dView = segue.destination as? ResourceDisplayVC {
                dView.resource = resource.makeHashableStruct()
            }
           
            
        }
        else
        {
            return
        }
    }
    
}
