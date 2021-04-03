//
//  ProfileResourceViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/24/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class ProfileResourceViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    var resources: [Resource] = []
    var profile = Profile()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.generateArray()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func generateArray(){
        //print("HEREHERHERHERHERHE" + self.profile.uid)
        resources = []
        if profile.uid != "" {
            db.collection("users").document(profile.uid).collection("POSTEDRESOURCES").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    // probably no poste resources associated with profile
                    print("Error getting resource \(err)")
                } else {
                    for resource in querySnapshot!.documents {
                        let path = resource.reference.path
                        let tempResource = Resource(base: self.db, path_: path)
                        tempResource.readData(database: self.db, path: path, tableview: self.tableView)
                        self.resources.append(tempResource)
                        //self.tableView.reloadData()
                    }
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ProfileResourceViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return resources.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = resources[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileResourceCell") as! ResourceCell
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
        self.performSegue(withIdentifier: "showProfileResourceSegue", sender: Any?.self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileResourceSegue"
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
