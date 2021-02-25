//
//  ViewMsgViewController.swift
//  AccountabilityPods
//
//  Created by KAHAN-THOMAS, JHADA L on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

class ViewMsgViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var msgs : [Skill] = []
    var userID = Constants.User.sharedInstance.userID
    let db = Firestore.firestore()
    @IBOutlet weak var msgTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        msgTable.delegate = self
        msgTable.dataSource = self
        reload()
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func reload()
    {
        print("Notified")
        self.msgs = []
        //print("Resources cleared: \(resources)")
        popArr()
        msgTable.reloadData()
        
    }
    func popArr() {
        msgs = []
        db.collection("users").document(userID).collection("MSG").getDocuments() { skillRefs,err in
            if let err = err {
                print(err)
            }
            else
            {
                for msgDoc in skillRefs!.documents {
                let tempMsg = Skill()
                self.msgs.append(tempMsg)
                tempMsg.readData(database: self.db, path: msgDoc.reference.path, tableview: self.msgTable)            }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skill = msgs[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgCell") as! SkillCell
        cell.setSkill(skill: skill)
        return cell    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
/*import UIKit
import Firebase

class ViewMsgsTableViewController: UITableViewController {

    var msgs : [Skill] = []
    var userID = Constants.User.sharedInstance.userID
    let db = Firestore.firestore()
    
    @IBOutlet weak var msgTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        msgTable.delegate = self
        msgTable.dataSource = self
    }
    @objc func reload()
    {
        print("Notified")
        self.msgs = []
        //print("Resources cleared: \(resources)")
        popArr()
        msgTable.reloadData()
        
    }
    func popArr() {
        msgs = []
        db.collection("users").document(userID).collection("MSG").getDocuments() { skillRefs,err in
            if let err = err {
                print(err)
            }
            else
            {
                for msgDoc in skillRefs!.documents {
                let tempMsg = Skill()
                self.msgs.append(tempMsg)
                tempMsg.readData(database: self.db, path: msgDoc.reference.path, tableview: self.msgTable)            }
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return msgs.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skill = msgs[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgCell") as! SkillCell
        cell.setSkill(skill: skill)
        return cell
        
    }
    }*/
