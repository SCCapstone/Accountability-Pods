//
//  ResourceViewCollectionVC.swift
//  AccountabilityPods
//
//  Created by duncan evans on 2/12/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase

// Small struct which functions as the folders
struct Group: Hashable {
    let uuid = UUID()
    let name: String
    var resources: [ResourceHashable]
}

struct GroupUnhashed {
    let name: String
    var resources: [Resource]
}

@available(iOS 14.0, *)
class ResourceViewCollectionVC: UIViewController {
    // Required
    enum ViewSection {
        case main
    }
    let db = Firestore.firestore()
    var data: UICollectionViewDiffableDataSource<ViewSection, ListType>!
    
    // Define the various arrays stored here-- this is not optimal, but it is acceptable.
    var resources: [ResourceHashable] = []
    var resourcesUnhashed: [Resource] = []
    var groups: [Group] = []
    var groupsUnhashed: [GroupUnhashed] = []
    var selectedResource: ResourceHashable = ResourceHashable(name:"none",desc:"none",path:"nil")
    
    //Enum allows for properly creating the cells
    enum ListType: Hashable {
        case group(Group)
        case resource(ResourceHashable)
    }
    // The main snapshot for the entire collection view
    var snapshotMain: NSDiffableDataSourceSnapshot<ViewSection, ListType>!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        // Immediately set up observer so if there is any saved resource change, i.e. a user likes or unlikes a post, or moves it to/from a group, the update function is called.
        NotificationCenter.default.addObserver(self, selector: #selector(self.genArray), name: NSNotification.Name(rawValue: "SavedResourceChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: NSNotification.Name(rawValue: "ResourceAsyncFinished"), object: nil)
        
        
        super.viewDidLoad()
        
        //Populate both the grouped and ungrouped resource arrays
        genArray()
        
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped);
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig);
        
        collectionView.collectionViewLayout = listLayout
        
        let resourceCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ResourceHashable> {
            (cell, indexPath, resource) in
            
            var contents = cell.defaultContentConfiguration()
            contents.text = resource.name
            contents.image = UIImage(systemName: "bolt.fill")
            
            cell.contentConfiguration = contents
        }
        
        let groupCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, Group> {
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
            case .resource(let resource):
                let cell = collectionView.dequeueConfiguredReusableCell(using: resourceCellReg, for: indexPath, item: resource)
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
            
            let resourceItem = group.resources.map { ListType.resource($0)}
            snapshotSection.append(resourceItem, to: groupItem)
            snapshotSection.expand([groupItem])
        }
        
        for resource in resources {
            let resourceItem = ListType.resource(resource)
            snapshotSection.append([resourceItem])
            //snapshotSection.expand([resourceItem])
            
        }
       // data.apply(snapshotResources, to: .main, animatingDifferences: false)
        data.apply(snapshotSection, to: .main, animatingDifferences: false)
        self.collectionView.reloadData()
        
        
       
        collectionView.delegate = self;
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func update()
    {
        
        resources = []
        self.collectionView.reloadData()
        for resource in self.resourcesUnhashed {
            resources.append(resource.hashableResource)
        }
        
        groups = []
    
        for group in self.groupsUnhashed {
            
            var tempGroup = Group(name:group.name,resources: [])
            for res in group.resources
            {
                print("--------asdasd------- " + res.name)
                tempGroup.resources.append(res.hashableResource)
            }
            groups.append(tempGroup)
        }
        
        
        let resourceCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ResourceHashable> {
            (cell, indexPath, resource) in
            
            var contents = cell.defaultContentConfiguration()
            contents.text = resource.name
            contents.image = UIImage(systemName: "bolt.fill")
            
            cell.contentConfiguration = contents
        }
        
        let groupCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, Group> {
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
            case .resource(let resource):
                let cell = collectionView.dequeueConfiguredReusableCell(using: resourceCellReg, for: indexPath, item: resource)
                return cell
            }
        }
       
        
        var snapshotSection = NSDiffableDataSourceSectionSnapshot<ListType>()
        
        for group in groups {
            
            let groupItem = ListType.group(group)
            snapshotSection.append([groupItem])
            
            let resourceItem = group.resources.map { ListType.resource($0)}
            snapshotSection.append(resourceItem, to: groupItem)
            snapshotSection.expand([groupItem])
        }
        
        
        for resource in resources {
            let resourceItem = ListType.resource(resource)
            snapshotSection.append([resourceItem])
            //snapshotSection.expand([resourceItem])
            
        }
        data.apply(snapshotSection, to: .main, animatingDifferences: false)
    }
    
    //Populate the hashable arrays with resources
    @objc func genArray(){
        resourcesUnhashed = []
        groupsUnhashed = []
        let usersRef = db.collection("users")
        let currUserRef = usersRef.document(Constants.User.sharedInstance.userID)
        let savedResourceRef = currUserRef.collection("SAVEDRESOURCES")
        savedResourceRef.getDocuments() {
            docsSnap, error in
            if let error = error {
                print("Error getting saved resources. \(error)")
            }
            else
            {

                for doc in docsSnap!.documents {
                    
                    let path = doc.data()["docRef"] as! String
                    //print("\n\n\n\n\n" + path + "\n\n\n\n\n")
                    let newResource = Resource(base: self.db, path_:path)
                    newResource.readData(database: self.db, path: path, collectionview: self.collectionView)
                                
                                //print(newResource.name)
                    let tempName = doc.data()["groupName"] as! String
                    if(tempName == "")
                    {
                    self.resourcesUnhashed.append(newResource)
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
                                //group.resources.append(newResource)
                                self.groupsUnhashed[i].resources.append(newResource)
                            }
                            i+=1
                        }
                        if(!isNameLogged)
                        {
                            var tempGroup = GroupUnhashed(name:tempName,resources:[])
                            tempGroup.resources.append(newResource)
                            self.groupsUnhashed.append(tempGroup)
                            
                        }
                        
                        
                    }
                                
                                
                                
                            }
                
                
                        }
                        
                    }
        
       
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResourceSegue"
        {
            
            if let dView = segue.destination as? ResourceDisplayVC {
                dView.resource = self.selectedResource
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
extension ResourceViewCollectionVC: UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        guard let selectedResource = data.itemIdentifier(for:indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
       
        
        switch selectedResource {
        case .resource(let resource):
            self.selectedResource = resource
            self.performSegue(withIdentifier: "showResourceSegue", sender: Any?.self)
            break;
        default:
            break;
            
        }
        
        return
    }
    
    
    
}



