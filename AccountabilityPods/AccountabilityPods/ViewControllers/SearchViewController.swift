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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        table.delegate = self
        table.dataSource = self
        field.delegate = self
    }
    
    private func setupData() {
        let usersRef = db.collection("users")
        
        usersRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting users for searching: \(err)")
            }
            else {
                print("Loading Users for Search Display")
                for document in querySnapshot!.documents {
                    if document.documentID != "adminuser" {
                        let tempProfile = Profile()
                        self.profiles.append(tempProfile)
                        tempProfile.readData(database: self.db, path: document.reference.path, tableview: self.table)                    }
                    
                }
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text {
            filterText(text + string)
        }
        table.reloadData()
        return true
    }
    
    func filterText(_ query: String) {
        print("QUERY: \(query)")
        filteredProfiles.removeAll()
        for profile in profiles {
            let userString = profile.userName
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
