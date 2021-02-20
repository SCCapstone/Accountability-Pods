//
//  ViewSkillsViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 12/3/20. Code written by Duncan Evans
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class ViewSkillsViewController: UIViewController {
    var skills : [Skill] = []
    let db = Firestore.firestore()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateArray()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "OnEditSkill"), object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func reload()
    {
        print("Notified")
        self.skills = []
        //print("Resources cleared: \(resources)")
        generateArray()
        tableView.reloadData()
        
    }
    
    func generateArray()
    {
        
        skills = []
        db.collection("users").document(Constants.User.sharedInstance.userID).collection("SKILLS").getDocuments() {
            skillRefs,err in
            if let err = err {
                print(err)
            }
            else
            {
                for skillDoc in skillRefs!.documents {
                    let tempSkill = Skill()
                    self.skills.append(tempSkill)
                    tempSkill.readData(database: self.db, path: skillDoc.reference.path, tableview: self.tableView)
                    print(tempSkill.name)
                    
                }
            }
        }
    }

}
extension ViewSkillsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skill = skills[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SkillCell") as! SkillCell
        
        cell.setSkill(skill: skill)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showSkillSegue", sender: Any?.self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSkillSegue"
        {
            let indexPath = self.tableView.indexPathForSelectedRow
            let skill = self.skills[(indexPath?.row)!]
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
