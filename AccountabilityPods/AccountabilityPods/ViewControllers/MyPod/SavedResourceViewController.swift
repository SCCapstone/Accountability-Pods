//
//  SavedResourceViewController.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class SavedResourceViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let db = Firestore.firestore()
    
    var resources: [Resource] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.genArray()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "OnResourceDismissal"), object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func reload()
    {
        print("Notified")
        self.resources = []
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
        let savedResourceRef = currUserRef.collection("SAVEDRESOURCES")
        print("I HAVE MADE IT HERE")
        savedResourceRef.getDocuments() {
            docsSnap, error in
            if let error = error {
                print("Error getting saved resources. \(error)")
            }
            else
            {

                for doc in docsSnap!.documents {
                    let path = doc.data()["docRef"] as! String
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

extension SavedResourceViewController: UITableViewDataSource, UITableViewDelegate {
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
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResourceSegue"
        {
            let indexPath = self.tableView.indexPathForSelectedRow
            let resource = self.resources[(indexPath?.row)!]
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
