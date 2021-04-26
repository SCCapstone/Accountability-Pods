//
//  ResourceBrowseViewController.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/3/20.
//  May be removed in the near future
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
// Description: The view controller for the HOME page

import UIKit
import Firebase
class ResourceBrowseViewController: UIViewController {
    // MARK: - Class Variables
    /// The table with the different posts
    @IBOutlet weak var tableView: UITableView!
    /// Array of resource posts to populate table
    var resources: [Resource] = []
    /// The firestore database
    let db = Firestore.firestore()
    /// The object for refreshing the table, gets new posts
    let refresh = UIRefreshControl()
    /// bool value for managing refresh start and finish
    var finishedRefreshing = true;

    // MARK: - Set up
    
    override func viewDidLoad() {
        // set up refresh functionality
        refresh.addTarget(self, action: #selector(self.reload(_:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "Fetching resources")
        tableView.refreshControl = refresh;
        
        // make sure someone is signed in before loading page
        if(Constants.User.sharedInstance.userID != "")
        {
            // update table if new contact is added
            NotificationCenter.default.addObserver(self, selector: #selector(self.genArray), name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
            super.viewDidLoad()
            // page only works with light mode
            overrideUserInterfaceStyle = .light
            // populate resources array with information from database
            genArray()
            // assign table view to proper classes
            tableView.delegate = self
            tableView.dataSource = self
        } else {
            print("Should not be logged in.");
        }
        
    }
    
    /// Hides keyboard when other part of screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Function called when user refreshes the page
    ///
    /// - Parameter sender: the object calling for refresh
    @objc func reload(_ sender: Any) {
        if(finishedRefreshing)
        {
            finishedRefreshing = false;
            // repopulate the resource array
            self.genArray();
        }
        refresh.endRefreshing();
    }
    
    /// Populates resources array with resource objects basedon information in database
    @objc func genArray(){
        // clear the array
        self.resources = []
        // get all users
        let usersRef = db.collection("users")
        /// get the current users contacts
        let currUserRef = usersRef.document(Constants.User.sharedInstance.userID)
        let userContactRef = currUserRef.collection("CONTACTS")
        /// look through users contacts
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
                            // get posts from users contact
                            for doc in resourceSnaps!.documents {
                                let path = doc.reference.path
                               // print("AEIOU")
                                let newResource = Resource(base: self.db, path_:path)
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
                // mark where refreshing should be complete
                self.finishedRefreshing = true
            }
        }
    }
    
    /// Sorts the resources using linear sort on their timestamp
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

// MARK: - Table Functionality

extension ResourceBrowseViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// Returns number of sections for the table.
    ///
    /// - Parameter tableView: the resource table
    /// - Returns: the number of resources in the array
    func numberOfSections(in tableView: UITableView) -> Int {
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
        return 0
    }
    /// Sets the height of the space between resource cells
    ///
    /// - Parameter:
    ///   - tableView: the resource table
    ///   - heightForHeaderInSection: the height of the space between cells
    /// - Returns: the height (10) for the space between cells
    func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    /// Shows and makes cosmetic changes to space between cells
    ///
    /// - Parameter:
    ///   - tableView: the skills table
    ///   - viewForHeaderInSection section: the index of the cell
    /// - Returns: the headerView with cosmetic changes
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        // changes background color of the header to be a clear space between cells
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
   
    /// Performs transition to detailed resource display
    ///
    /// - Parameter:
    ///   - tableView: the resource table
    ///   - indexPath: the index of the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showResourceSegue", sender: Any?.self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    /// Prepares the transition to the own resource viewer
    ///
    /// - Parameter:
    ///   - segue: the segue in the storyboard between this view and the own resource view
    ///   - sender: the cell that was tapped
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
