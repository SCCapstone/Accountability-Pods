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
        print("Profile id: \(profile.uid)")
        self.generateArray()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    
    func generateArray() {
        skills = []
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let skill = skills[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSkillCell") as! SkillCell
            
            cell.setSkill(skill: skill)
            return cell
    }
    // TODO: create view in main.storyboard to segue to when skill tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}
