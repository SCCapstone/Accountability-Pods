import UIKit
import Firebase
class OwnSkillViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var nameEdit: UITextField!
    var userIsEditing: Bool = false
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    var skill: Skill = Skill()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureText()
        // Do any additional setup after loading the view.
    }
    func configureText()
    {
        desc.text = skill.desc
        nameLabel.text = skill.name
    }
    
    @IBAction func editResource(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditSkill"), object: nil)
        if(userIsEditing)
        {
            nameEdit.isHidden = true
            nameLabel.isHidden = false
            userIsEditing = false
            editButton.tintColor = .black
            desc.isEditable = false
            nameLabel.text = nameEdit.text
            nameLabel.isEnabled = true
            nameEdit.isEnabled = false
            nameEdit.isUserInteractionEnabled = false
            
            db.document(skill.path).setData(["skillName" : nameLabel.text, "skillDescription" : desc.text]) {err in
                if let err = err {
                    print(err)
                }
            }
            
            
        }
        else
        {
            userIsEditing = true
            nameLabel.isHidden = true
            editButton.tintColor = .blue
            desc.isEditable = true
            nameEdit.text = nameLabel.text
            nameLabel.isEnabled = false
            nameEdit.isEnabled = true
            nameEdit.isUserInteractionEnabled = true
            nameEdit.isHidden = false
            
        }
    
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let docID = db.document(skill.path).documentID
        db.collection("users").document(Constants.User.sharedInstance.userID).collection("SKILLS").document((docID)).delete()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OnEditSkill"), object: nil)
        self.dismiss(animated: true)
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
