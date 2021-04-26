//
//  SkillViewController.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/24/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//
//  Description: Detailed description of someone else's skill

import UIKit

class SkillViewController: UIViewController {

    // MARK: - Class Variables
    
    /// The name of the other users skill
    @IBOutlet weak var skillNameLabel: UILabel!
    /// The description of the  other users skill
    @IBOutlet weak var SkillDescTextView: UITextView!
    /// The skill object that was sent from table
    var skill: Skill = Skill()
    
    // MARK: - Set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // page only works with light mode
        overrideUserInterfaceStyle = .light
        // sets text on the page
        configureText()
    }
    
    /// Set labels to the appropraite value from skill object
    func configureText() {
        SkillDescTextView.text = skill.desc
        skillNameLabel.text = skill.name
    }
    
    /// Hides keyboard when other part of screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
