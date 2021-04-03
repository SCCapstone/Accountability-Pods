//
//  ProfileSkillsViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/24/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

class ProfileSkillsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var skills : [Skill] = []
    let db = Firestore.firestore()
    var profile = Profile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        //print("Profile id: \(profile.uid)")
        self.generateArray()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func generateArray() {
        skills = []
        //profile.uid = Constants.User.sharedInstance.userID
        if profile.uid != "" {
            db.collection("users").document(profile.uid).collection("SKILLS").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    // probably no skills associated with profile
                    print("Error getting skills \(err)")
                } else {
                    for skill in querySnapshot!.documents {
                        let tempSkill = Skill()
                        self.skills.append(tempSkill)
                        tempSkill.readData(database: self.db, path: skill.reference.path, tableview: self.tableView)
                        print(tempSkill.name)
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
extension ProfileSkillsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.skills.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let skill = skills[indexPath.section]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSkillCell") as! SkillCell
            
            cell.setSkill(skill: skill)
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
        self.performSegue(withIdentifier: "showProfileSkillSegue", sender: Any?.self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileSkillSegue"
        {
            let indexPath = self.tableView.indexPathForSelectedRow
            let skill = self.skills[(indexPath?.section)!]
            if let dView = segue.destination as? SkillViewController {
                dView.skill = skill
            }
        }
        else
        {
            return
        }
    }
    
}
