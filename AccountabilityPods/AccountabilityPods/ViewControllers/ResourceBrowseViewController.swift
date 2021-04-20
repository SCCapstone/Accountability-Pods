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
    let refresh = UIRefreshControl()
    var finishedRefreshing = true;

    override func viewDidLoad() {
        
        refresh.addTarget(self, action: #selector(self.reload(_:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "Fetching resources")
        tableView.refreshControl = refresh;

        if(Constants.User.sharedInstance.userID != "")
        {
        NotificationCenter.default.addObserver(self, selector: #selector(self.genArray), name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
       
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        genArray()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        print("Test: Loading Resources")
        }
        else
        {
            print("Should not be logged in.");
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func reload(_ sender: Any) {
        if(finishedRefreshing)
        {
            finishedRefreshing = false;
        self.genArray();
        }
        refresh.endRefreshing();
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
                self.finishedRefreshing = true;

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
                                
                                print("Resource: \(newResource.name)")
                                
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
                self.finishedRefreshing = true
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

extension ResourceBrowseViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sortResources()
        return self.resources.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(indexPath.section)
        //print(resources.count)
        if(resources.count == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell") as! ResourceCell
            
            cell.setResource(resource: Resource())
            cell.layer.cornerRadius = 15
            return cell
        }
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
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
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
