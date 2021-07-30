//
//  PostedResourcesViewController.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: manages the subview on the own profile page that shows user's posts.

import UIKit
import Firebase
class PostedResourcesViewController: UIViewController {
    
    // MARK: - UI Connectors
    
    /// The table of skills
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Class Variables
    
    /// The firestore database
    let db = Firestore.firestore()
    /// Array of resource objects (see class in utilities) to be shown in table.
    var resources: [Resource] = []
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set page to only work with light mode
        overrideUserInterfaceStyle = .light
        // adds data to resource array 
        self.genArray()
        // sorts the resources in the order they were posted
        self.sortResources()
        // Attaches UI delegate and datasource to the table
        tableView.delegate = self
        tableView.dataSource = self
        // Retrieves notifications if resources have been added, deleted, or edited
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "OnEditResource"), object: nil)
    }
   
    /// Reloads the data in the resource table when called
    @objc func reload()
    {
        print("Notified")
        // clear the resource array
        self.resources = []
        print("Resources cleared: \(resources)")
        // add resources to the array
        genArray()
        // reload the table
        tableView.reloadData()
        
    }
    
    /// Sets keyboard to hide when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Adds resource objects to resource array from information in database
    func genArray(){
        // clear the list of resources
        self.resources = []
        // get the resource documents from the database
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
                     // add newly created resource to array        
                    self.resources.append(newResource)
                    // reload the table with new data
                    self.tableView.reloadData()
                 }
             }
                        
          }
    }
    
    /// Linear sort of resources in array based on the timeStamp
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
    
    // MARK: - Table functions
    
    /// Returns number of sections for the table.
    ///
    /// - Parameter tableView: the resource table
    /// - Returns: the number of resources in the array
    func numberOfSections(in tableView: UITableView) -> Int {
        // sorts resources by time stamp
        sortResources()
        return self.resources.count
    }
    
    /// Returns number of rows that should be in each section.
    ///
    /// - Parameters:
    ///   - tableView: the resource table
    ///   - numberOfRowsInSection section: the number of rows to be in each section
    /// - Returns: int 1, since there should be one row per section 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    /// Returns cell for given indexPath
    ///
    /// - Parameters:
    ///   - tableView: the resource table
    ///   - indexPathL the index of the cell 
    /// - Returns: the cell to be placed in table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// get resource for given index
        let resource = resources[indexPath.section]
        print("INDEXX: \(indexPath.section)")
        // set up cell (see ResourceCell.swift)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell") as! ResourceCell
        print("OWNNN: \(resource.name)")
        // Set resource cell information from resource object
        cell.setResource(resource: resource)
        // cosmetically change cell
        cell.layer.cornerRadius = 15
        return cell
        
    }
    
    /// Performs transition to detail own resource display
    /// 
    /// - Parameter:
    ///   - tableView: the resource table
    ///   - indexPath: the index of the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // performs segue in storyboard
        self.performSegue(withIdentifier: "showOwnSegue", sender: Any?.self)
        // deselects the row after segue 
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    /// Sets the height of the space between resource cells
    ///
    /// - Parameter:
    ///   - tableView: the resource table
    ///   - heightForHeaderInSection: the height of the space between cells
    /// - Returns: the height (10) for the space between cells
    func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        return 10
    }
    /// Sets the height of the space between  cells
    ///
    /// - Parameter:
    ///   - tableView: the contact table
    ///   - heightForHeaderInSection: the height of the space between cells
    /// - Returns: the height (10) for the space between cells
    func  tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == resources.count - 1 {
            return 20
        }
        return 10
    }
    /// Shows and makes cosmetic changes to space between cells
    ///
    /// - Parameter:
    ///   - tableView: the resource table
    ///   - viewForHeaderInSection section: the index of the cell
    /// - Returns: the headerView with cosmetic changes
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        // changes background color of header
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
    /// Prepares the transition to the own resource viewer
    ///
    /// - Parameter: 
    ///   - segue: the segue in the storyboard between this view and the own resource view
    ///   - sender: the cell that was tapped
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOwnSegue"
        {
            let indexPath = self.tableView.indexPathForSelectedRow
            // the resource of the selected cell
            let resource = self.resources[(indexPath?.section)!]
            // sends the resource to the new own resource view
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
