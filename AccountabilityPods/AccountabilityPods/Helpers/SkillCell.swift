//
//  ProfileCell.swift
//  AccountabilityPods
//
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//
//  Description: Class for a cell in any table that has skills (own skills, other users skills)
import UIKit
class SkillCell: UITableViewCell {
    /// The name of skill in the cell
    @IBOutlet weak var skillName: UILabel!

    /// Sets the text in the cell from data in a given skill obejct
    ///
    /// - Parameter skill: the skill object displayed in the cell (passed from table controller)
    func setSkill(skill: Skill)
    {
        self.skillName.text = skill.name
        
    }
}
