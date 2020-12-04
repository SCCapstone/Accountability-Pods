

import UIKit
class SkillCell: UITableViewCell {

    @IBOutlet weak var skillName: UILabel!

    
    func setSkill(skill: Skill)
    {
        self.skillName.text = skill.name
        
    }
}
