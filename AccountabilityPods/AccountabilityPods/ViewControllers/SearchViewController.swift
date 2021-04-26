//
//  SearchViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/20/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//
//  Description: Manages the search page

import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    /// The table of profiles
    @IBOutlet var table: UITableView!
    /// The search field
    @IBOutlet var field: UITextField!
    /// The firestore database
    let db = Firestore.firestore()
    /// An array of all of the public users
    var profiles = [Profile]()
    /// An array of profiles that match the search text
    var filteredProfiles = [Profile]()
    /// Whether filtering has occured
    var filtered = false
    /// Whether refreshing has finished
    var finishedRefreshing = true;
    /// The username of the current user
    var userID = Constants.User.sharedInstance.userID
    /// The refresh object
    let refresh = UIRefreshControl()

    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // page only shows light mode
        overrideUserInterfaceStyle = .light
        // load data into the profiles array
        setupData()
        // table has delegate and datasource functionality
        table.delegate = self
        table.dataSource = self
        // search field has delegate functionality
        field.delegate = self
        // page refreshes when it opens
        table.refreshControl = refresh;
        // sets up refreshing functionality
        refresh.addTarget(self, action: #selector(self.reload(_:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "Fetching new messages")
    }
    
    /// Loads profile objects into the profiles array
    private func setupData() {
        // clear the array
        self.profiles.removeAll()
        let usersRef = db.collection("users")
        // get all users from DB
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting users for searching: \(err)")
                self.finishedRefreshing = true;
            }
            else {
                print("Loading Users for Search Display")
                for document in querySnapshot!.documents {
                    if document.documentID != "adminuser" && document.documentID != self.userID {
                        if document.get("private") as? Int != 1 && document.get("username") != nil{
                            // add user to array
                            let tempProfile = Profile()
                            self.profiles.append(tempProfile)
                            tempProfile.readData(database: self.db, path: document.reference.path, tableview: self.table)
                        }
                                            
                    }
                    
                }
                self.finishedRefreshing = true;
            }
        }
    }
    
    /// Calls filterText() to filter the array with search query when search is pressed
    @IBAction func searchPressed(_ sender: Any) {
        if let text = field.text{
            // removes whitespaces
            let clean_text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            // check if there are only spaces, should search for that whitespace
            if text.count > 0 && clean_text.count == 0 {
                filterText(text)
            } else {
                filterText(clean_text)
            }
        }
        else
        {
            filtered = false;
        }
        // reload the table with the filtered data
        table.reloadData()
    }
    
    /// Populates filteredProfiles array with profiles that match the query
    func filterText(_ query: String) {
        print("QUERY: \(query)")
        filteredProfiles.removeAll()
        // checks for profile contents that start with the query
        for profile in profiles {
            let userString = profile.uid
            let firstString = profile.firstName
            let lastString = profile.lastName
            if (userString.lowercased().starts(with: query.lowercased()) || firstString.lowercased().starts(with: query.lowercased()) || lastString.lowercased().starts(with: query.lowercased()))
            {
                print("starts with profile: \(profile.uid)")
                filteredProfiles.append(profile)
                table.reloadData()
            }
        }
        // checks for profile contents that contain query if query is more than one letter (added after so most relevant profiles come first)
        if query.count > 1 {
            for profile in profiles {
                let userString = profile.uid
                let firstString = profile.firstName
                let lastString = profile.lastName
                if (userString.lowercased().contains(query.lowercased()) || firstString.lowercased().contains(query.lowercased()) || lastString.lowercased().contains(query.lowercased()))
                {
                    var notInFiltered = true
                    for fprofile in filteredProfiles {
                        if fprofile.uid == profile.uid {
                            notInFiltered = false
                        }
                    }
                    if notInFiltered {
                        print("contained in profile: \(profile.uid)")
                        filteredProfiles.append(profile)
                        table.reloadData()
                    }
                    
                }
            }
        }
        // if query is empty all profiles should show 
        if query.isEmpty {
            filtered = false
            filteredProfiles.removeAll()
        } else {
            filtered = true
        }
        print("FILTERED: \(filtered)")
        table.reloadData()
        
    }
    
    // MARK: - Table functions
    
    /// Set number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredProfiles.isEmpty {
            // return filtered profiles count if there array has members
            return filteredProfiles.count
        }
        return filtered ? 0 : profiles.count
    }
    
    /// Reloads the table when refreshed
    @objc func reload(_ sender: Any) {
        if(finishedRefreshing)
        {
            finishedRefreshing = false;
        self.setupData();
        }
        refresh.endRefreshing();
    }
    
    /// Creates and adds profile cells to the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("filling cells")
        let cell = table.dequeueReusableCell(withIdentifier: "cell") as! ProfileCell
        /// add from filtered array when it is not empty
        if !filteredProfiles.isEmpty {
            print("showing filtered profiles")
            if(indexPath.row < filteredProfiles.count)
            {
            let profile = filteredProfiles[indexPath.row]
            cell.setProfile(profile: profile)
            }
        } else if !profiles.isEmpty{
            // add all profiles when filtered profiles is empty
            print("showing all profiles")
            if(indexPath.row >= profiles.count)
            {
                print("Index out of bounds caught!")
            
            }
            else
            {
                let profile = profiles[indexPath.row]
                cell.setProfile(profile: profile)
            }
        }
        return cell
    }
    /// Show the users profile when cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showProfileSegue", sender: Any?.self)
    }
    
    /// Prepares for the transition to the detailed profile
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileSegue" {
            let indexPath = self.table.indexPathForSelectedRow
            // if filtered profiles are showing
            if filtered {
                let profile = self.filteredProfiles[(indexPath?.row)!]
                if let dView = segue.destination as? ProfileViewController {
                    dView.profile = profile
                }
            } else {
                // if all profiles are showing
                let profile = self.profiles[(indexPath?.row)!]
                if let dView = segue.destination as? ProfileViewController {
                    dView.profile = profile
                }
            }
        }
    }
    
    // MARK: - UI functions
    
    /// Explains how search page works when (?) is tapped
    @IBAction func helpTapped(_ sender: Any) {
        // prepares and presents alert
        let alertController = UIAlertController(title: "Search Help", message: "Type someones username or name information and press search to search for their profile\nTo see all profiles clear the search bar and press search\nTap on profile to view and add them to your pod\nYou will not be able to search for any private accounts", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    
    // Hides keyboard when other part of screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    

}
