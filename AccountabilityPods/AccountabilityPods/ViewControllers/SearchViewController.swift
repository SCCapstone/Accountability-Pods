//
//  SearchViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/20/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet var field: UITextField!
    
    let db = Firestore.firestore()
    var data = [String]()
    var profiles = [Profile]()
    var filteredData = [String]()
    var filteredProfiles = [Profile]()
    var filtered = false
    var finishedRefreshing = true;
    var userID = Constants.User.sharedInstance.userID
    let refresh = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupData()
        table.delegate = self
        table.dataSource = self
        field.delegate = self
        table.refreshControl = refresh;

        refresh.addTarget(self, action: #selector(self.reload(_:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "Fetching users")
    }
    
    private func setupData() {
        self.profiles.removeAll()
        let usersRef = db.collection("users")
        
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
    
    
    @IBAction func searchPressed(_ sender: Any) {
        if let text = field.text {
            filterText(text)
        }
        else
        {
            filtered = false;
        }
        table.reloadData()
    }
    func filterText(_ query: String) {
        print("QUERY: \(query)")
        filteredProfiles.removeAll()
        for profile in profiles {
            let userString = profile.uid
            let firstString = profile.firstName
            let lastString = profile.lastName
            if (userString.lowercased().starts(with: query.lowercased()) || firstString.lowercased().starts(with: query.lowercased()) || lastString.lowercased().starts(with: query.lowercased()))
            {
                filteredProfiles.append(profile)
                table.reloadData()
            }
        }
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filtered = false
            filteredProfiles.removeAll()
        } else {
            filtered = true
        }
        print("FILTERED: \(filtered)")
        table.reloadData()
        
    }
    // set number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredProfiles.isEmpty {
            return filteredProfiles.count
        }
        return filtered ? 0 : profiles.count
    }
    @objc func reload(_ sender: Any) {
        if(finishedRefreshing)
        {
            finishedRefreshing = false;
        self.setupData();
        }
        refresh.endRefreshing();
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("filling cells")
        let cell = table.dequeueReusableCell(withIdentifier: "cell") as! ProfileCell
        if !filteredProfiles.isEmpty {
            print("showing filtered profiles")
            let profile = filteredProfiles[indexPath.row]
            cell.setProfile(profile: profile)
        } else {
            print("showing all profiles")
            let profile = profiles[indexPath.row]
            cell.setProfile(profile: profile)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showProfileSegue", sender: Any?.self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileSegue" {
            let indexPath = self.table.indexPathForSelectedRow
            print("index: \(indexPath)")
            if filtered {
                let profile = self.filteredProfiles[(indexPath?.row)!]
                if let dView = segue.destination as? ProfileViewController {
                    dView.profile = profile
                }
            } else {
                let profile = self.profiles[(indexPath?.row)!]
                if let dView = segue.destination as? ProfileViewController {
                    dView.profile = profile
                }
            }
        }
    }
    @IBAction func helpTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Search Help", message: "Type someones username or name information and press search to search for their profile\nTo see all profiles clear the search bar and press search\nTap on profile to view and add them to your pod\nYou will not be able to search for any private accounts", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:"Got it!", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
