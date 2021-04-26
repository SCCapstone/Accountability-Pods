//
//  ViewSkillsViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 12/3/20. Code written by Duncan Evans
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
//  Description: Manages table of skills in skills subview on own profile page.

import UIKit
import Firebase
class ViewSkillsViewController: UIViewController {
    
    // MARK: - Class Variables
    
    /// Array of skill objects (see Utilities) that populate the skills table
    var skills : [Skill] = []
    /// The Firebase database
    let db = Firestore.firestore()
    /// The skills table 
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Page only works in light mode
        overrideUserInterfaceStyle = .light
        // populates skill array with skills from database
        self.generateArray()
        // assigns table functions to skills table
        tableView.delegate = self
        tableView.dataSource = self
        //  retrieves notification and updates table when skills are added, edited, or deleted
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "OnEditSkill"), object: nil)
    }
    
    /// Reloads table when update notification is recieved
    @objc func reload()
    {
        print("Notified")
        // clears array of skills
        self.skills = []
        // repopulates array of skills with updated skills
        generateArray()
        // reloads the table
        tableView.reloadData()
        
    }
    
    /// Hides keyboard when other spot on screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Populates array of skills from information in database
    func generateArray()
    {
        // clear skills
        skills = []
        // get skills from database
        db.collection("users").document(Constants.User.sharedInstance.userID).collection("SKILLS").getDocuments() {
            skillRefs,err in
            if let err = err {
                print(err)
            }
            else
            {
                for skillDoc in skillRefs!.documents {
                    let tempSkill = Skill()
                    // add skill to array
                    self.skills.append(tempSkill)
                    // adds database info to skill
                    tempSkill.readData(database: self.db, path: skillDoc.reference.path, tableview: self.tableView)
                    print(tempSkill.name)
                    
                }
            }
        }
    }

}
extension ViewSkillsViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table functions
    
    /// Returns number of sections for the table.
    ///
    /// - Parameter tableView: the skills table
    /// - Returns: the number of skills in the array
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.skills.count
    }
    
    /// Returns number of rows that should be in each section.
    ///
    /// - Parameters:
    ///   - tableView: the skills table
    ///   - numberOfRowsInSection section: the number of rows to be in each section
    /// - Returns: int 1, since there should be one row per section 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /// Returns cell for given indexPath
    ///
    /// - Parameters:
    ///   - tableView: the skill table
    ///   - indexPathL the index of the cell 
    /// - Returns: the cell to be placed in table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skill = skills[indexPath.section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SkillCell") as! SkillCell
        
        cell.setSkill(skill: skill)
        cell.layer.cornerRadius = 15

        return cell
        
    }
    
    /// Sets the height of the space between resource cells
    ///
    /// - Parameter:
    ///   - tableView: the skills table
    ///   - heightForHeaderInSection: the height of the space between cells
    /// - Returns: the height (20) for the space between cells
    func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    /// Sets the height of the space between  cells
    ///
    /// - Parameter:
    ///   - tableView: the contact table
    ///   - heightForHeaderInSection: the height of the space between cells
    /// - Returns: the height (10) for the space between cells
    func  tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == skills.count - 1 {
            return 20
        }
        return 0
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
    
    /// Performs transition to detailed own skill display
    /// 
    /// - Parameter:
    ///   - tableView: the skill table
    ///   - indexPath: the index of the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // perform segue in storyboard
        self.performSegue(withIdentifier: "showSkillSegue", sender: Any?.self)
        // deselects the row after segue
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

    }
    
    /// Prepares the transition to the own skill viewer
    ///
    /// - Parameter: 
    ///   - segue: the segue in the storyboard between this view and the own skill view
    ///   - sender: the cell that was tapped
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSkillSegue"
        {
            let indexPath = self.tableView.indexPathForSelectedRow
            // the skill in the selected cell
            let skill = self.skills[(indexPath?.section)!]
            // send the skill object to the own skill view
            if let dView = segue.destination as? OwnSkillViewController {
                dView.skill = skill
            }
        }
        else
        {
            return
        }
    }
    
}
