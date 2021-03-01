//
//  SkillViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/24/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit

class SkillViewController: UIViewController {

    @IBOutlet weak var skillNameLabel: UILabel!
    @IBOutlet weak var SkillDescTextView: UITextView!
    var skill: Skill = Skill()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        configureText()
        // Do any additional setup after loading the view.
    }
    
    func configureText() {
        SkillDescTextView.text = skill.desc
        skillNameLabel.text = skill.name
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
