//
//  ProfileViewCollectionVC.swift
//  AccountabilityPods
//
//  Created by duncan evans on 2/12/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

// Small struct which functions as the folders
struct ProfileGroup: Hashable {
    let uuid = UUID()
    let name: String
    var profiles: [ProfileHashable]
}

struct ProfileGroupUnhashed {
    let name: String
    var profiles: [Profile]
}

@available(iOS 14.0, *)
class ProfileViewCollectionVC: UIViewController {
    // Required
    enum ViewSection {
        case main
    }
    let db = Firestore.firestore()
    var data: UICollectionViewDiffableDataSource<ViewSection, ListType>!
    
    // Define the various arrays stored here-- this is not optimal, but it is acceptable.
    var profiles: [ProfileHashable] = []
    var profilesUnhashed: [Profile] = []
    var groups: [ProfileGroup] = []
    var groupsUnhashed: [ProfileGroupUnhashed] = []
    var selectedProfile: ProfileHashable = ProfileHashable()
    
    //Enum allows for properly creating the cells
    enum ListType: Hashable {
        case group(ProfileGroup)
        case profile(ProfileHashable)
    }
    // The main snapshot for the entire collection view
    var snapshotMain: NSDiffableDataSourceSnapshot<ViewSection, ListType>!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        // Immediately set up observer so if there is any saved profile change, i.e. a user likes or unlikes a post, or moves it to/from a group, the update function is called.
        NotificationCenter.default.addObserver(self, selector: #selector(self.genArray), name: NSNotification.Name(rawValue: "ContactsChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: NSNotification.Name(rawValue: "ProfileAsyncFinished"), object: nil)
        
        
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        //Populate both the grouped and ungrouped profile arrays
        genArray()
        
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped);
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig);
        
        collectionView.collectionViewLayout = listLayout
        
        let profileCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ProfileHashable> {
            (cell, indexPath, profile) in
            
            var contents = cell.defaultContentConfiguration()
            contents.text = (profile.firstName + " " + profile.lastName)
            contents.image = UIImage(systemName: "bolt.fill")
            
            cell.contentConfiguration = contents
        }
        
        let groupCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ProfileGroup> {
            (cell, indexPath, group) in
            var contents = cell.defaultContentConfiguration()
            contents.text = group.name
            contents.image = UIImage(systemName: "folder.fill")
            cell.contentConfiguration = contents
            
            let groupDisclose = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options:groupDisclose)]
            
        }
        
        
        
        
        data = UICollectionViewDiffableDataSource<ViewSection, ListType>(collectionView: collectionView) {
            (collectionView, indexPath, listType) -> UICollectionViewCell? in
            switch listType {
            case .group(let group):
                let cell = collectionView.dequeueConfiguredReusableCell(using: groupCellReg, for: indexPath, item: group)
                return cell
            case .profile(let profile):
                let cell = collectionView.dequeueConfiguredReusableCell(using: profileCellReg, for: indexPath, item: profile)
                return cell
            }
        }
        snapshotMain = NSDiffableDataSourceSnapshot<ViewSection,ListType>()
        snapshotMain.appendSections([.main])
        data.apply(snapshotMain,animatingDifferences: false)
        
        var snapshotSection = NSDiffableDataSourceSectionSnapshot<ListType>()
        
        for group in groups {
            
            let groupItem = ListType.group(group)
            snapshotSection.append([groupItem])
            
            let profileItem = group.profiles.map { ListType.profile($0)}
            snapshotSection.append(profileItem, to: groupItem)
            snapshotSection.expand([groupItem])
        }
        
        for profile in profiles {
            let profileItem = ListType.profile(profile)
            snapshotSection.append([profileItem])
            //snapshotSection.expand([profileItem])
            
        }
       // data.apply(snapshotProfiles, to: .main, animatingDifferences: false)
        data.apply(snapshotSection, to: .main, animatingDifferences: false)
        self.collectionView.reloadData()
        
        
       
        collectionView.delegate = self;
        
        
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func update()
    {
        
        profiles = []
        self.collectionView.reloadData()
        for profile in self.profilesUnhashed {
            profile.hash()
            profiles.append(profile.hashableProfile)
        }
        
        groups = []
    
        for group in self.groupsUnhashed {
            
            var tempGroup = ProfileGroup(name:group.name,profiles: [])
            for res in group.profiles
            {
                print("--------asdasd------- " + res.firstName)
                res.hash()
                tempGroup.profiles.append(res.hashableProfile)
            }
            groups.append(tempGroup)
        }
        
        
        let profileCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ProfileHashable> {
            (cell, indexPath, profile) in
            
            var contents = cell.defaultContentConfiguration()
            contents.text = profile.firstName + " " + profile.lastName
            contents.image = UIImage(systemName: "bolt.fill")
            
            cell.contentConfiguration = contents
        }
        
        let groupCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ProfileGroup> {
            (cell, indexPath, group) in
            var contents = cell.defaultContentConfiguration()
            contents.text = group.name
            contents.image = UIImage(systemName: "folder.fill")
            cell.contentConfiguration = contents
            
            let groupDisclose = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options:groupDisclose)]
            
        }
        
        
        
        
        data = UICollectionViewDiffableDataSource<ViewSection, ListType>(collectionView: collectionView) {
            (collectionView, indexPath, listType) -> UICollectionViewCell? in
            switch listType {
            case .group(let group):
                let cell = collectionView.dequeueConfiguredReusableCell(using: groupCellReg, for: indexPath, item: group)
                return cell
            case .profile(let profile):
                let cell = collectionView.dequeueConfiguredReusableCell(using: profileCellReg, for: indexPath, item: profile)
                return cell
            }
        }
       
        
        var snapshotSection = NSDiffableDataSourceSectionSnapshot<ListType>()
        
        for group in groups {
            
            let groupItem = ListType.group(group)
            snapshotSection.append([groupItem])
            
            let profileItem = group.profiles.map { ListType.profile($0)}
            snapshotSection.append(profileItem, to: groupItem)
            snapshotSection.expand([groupItem])
        }
        
        
        for profile in profiles {
            let profileItem = ListType.profile(profile)
            snapshotSection.append([profileItem])
            //snapshotSection.expand([profileItem])
            
        }
        data.apply(snapshotSection, to: .main, animatingDifferences: false)
    }
    
    //Populate the hashable arrays with profiles
    @objc func genArray(){
        profilesUnhashed = []
        groupsUnhashed = []
        let usersRef = db.collection("users")
        let currUserRef = usersRef.document(Constants.User.sharedInstance.userID)
        let savedProfileRef = currUserRef.collection("CONTACTS")
        savedProfileRef.getDocuments() {
            docsSnap, error in
            if let error = error {
                print("Error getting saved profiles. \(error)")
            }
            else
            {

                for doc in docsSnap!.documents
                {
                    if doc.documentID == "adminuser"
                    {
                        continue
                    }
                    else {
                    let path = "users/" + (doc.data()["userRef"] as! String)
                    //print("\n\n\n\n\n" + path + "\n\n\n\n\n")
                    let newProfile = Profile()
                    newProfile.readData(database: self.db, path: path, collectionview: self.collectionView)
                    
                                //print(newProfile.name)
                    if (doc.data()["groupName"] == nil)
                    {
                        doc.reference.setData(["groupName": ""],merge:true)
                        self.profilesUnhashed.append(newProfile)
                    }
                    else
                    {
                        let tempName = doc.data()["groupName"] as! String
                        if(tempName == "")
                        {
                        self.profilesUnhashed.append(newProfile)
                        }
                        else
                        {
                            
                            var isNameLogged = false
                            var i = 0;
                            for group in self.groupsUnhashed {
                               
                                if(group.name == tempName && !isNameLogged)
                                {
                                    print("Group name here: " + group.name)
                                    print("New name here: " + tempName)
                                    isNameLogged = true
                                    //group.profiles.append(newProfile)
                                    self.groupsUnhashed[i].profiles.append(newProfile)
                                }
                                i+=1
                            }
                            if(!isNameLogged)
                            {
                                var tempGroup = ProfileGroupUnhashed(name:tempName,profiles:[])
                                tempGroup.profiles.append(newProfile)
                                self.groupsUnhashed.append(tempGroup)
                                
                            }
                            
                            
                        }
                    }
                    
                                
                                
                    }
                }
                
                
                        }
                        
                    }
        
       
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileSegue"
        {
            
            if let dView = segue.destination as? ProfileViewController {
                var tempProf = Profile()
                tempProf.unHash(hashProfile:self.selectedProfile)
                dView.profile = tempProf
            }
           
            
        }
        else
        {
            return
        }
    }
    
    
    
    

    
    // MARK: - Extensions


}


@available(iOS 14.0, *)
extension ProfileViewCollectionVC: UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        guard let selectedProfile = data.itemIdentifier(for:indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
       
        
        switch selectedProfile {
        case .profile(let profile):
            self.selectedProfile = profile
            self.performSegue(withIdentifier: "showProfileSegue", sender: Any?.self)
            break;
        default:
            break;
            
        }
        
        return
    }
    
    
    
}



