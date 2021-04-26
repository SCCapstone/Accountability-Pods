//
//  ProfileResourceViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/24/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//
//  Description: Manages the table of another users post on their profile

import UIKit
import Firebase
class ProfileResourceViewController: UIViewController {
    // MARK: - Class Variable
    
    /// the resource table
    @IBOutlet weak var tableView: UITableView!
    /// firestore database
    let db = Firestore.firestore()
    /// array of resources to be displayed on the table
    var resources: [Resource] = []
    /// the profile object for the user
    var profile = Profile()
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Page only shows light mode
        overrideUserInterfaceStyle = .light
        /// Populates resources array with other
        self.generateArray()
        /// sets up table functionality
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// hides keyboard when other part of screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Populates resources array with resource objects from database
    func generateArray(){
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
    
    /// Does linear sort on resource array 
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
extension ProfileResourceViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sortResources()
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
    /// Sets the height for footer, only present in last cell
    ///
    /// - Parameter:
    ///   - tableView: the contact table
    ///   - heightForHeaderInSection: the height of the space between cells
    /// - Returns: the height (10) for the space between cells
    func  tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == resources.count - 1 {
            return 20
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    /// Shows and makes cosmetic changes to space between cells
    ///
    /// - Parameter:
    ///   - tableView: the contact table
    ///   - viewForHeaderInSection section: the index of the cell
    /// - Returns: the headerView with cosmetic changes
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        // changes background color of the header to be a clear space between cells
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showProfileResourceSegue", sender: Any?.self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
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
