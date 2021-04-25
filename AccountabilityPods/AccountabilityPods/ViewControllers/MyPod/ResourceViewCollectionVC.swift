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
struct ResourceGroup: Hashable {
    let uuid = UUID()
    let name: String
    var resources: [ResourceHashable]
}

struct ResourceGroupUnhashed {
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
    var groups: [ResourceGroup] = []
    var finishedRefreshing = true;
    var groupsUnhashed: [ResourceGroupUnhashed] = []
    var selectedResource: ResourceHashable = ResourceHashable(name:"none",desc:"none",path:"nil")
    var inputString = ""
    let refresh = UIRefreshControl()
    
    let alert = UIAlertController(title: "Create Group", message: "Enter your group name.", preferredStyle: .alert)
    
    
    
    @IBAction func createGroup(_ sender: Any) {
        self.present(alert, animated: true, completion: nil)
    }
    //Enum allows for properly creating the cells
    enum ListType: Hashable {
        case group(ResourceGroup)
        case resource(ResourceHashable)
    }
    // The main snapshot for the entire collection view
    var snapshotMain: NSDiffableDataSourceSnapshot<ViewSection, ListType>!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        // Immediately set up observer so if there is any saved resource change, i.e. a user likes or unlikes a post, or moves it to/from a group, the update function is called.
        NotificationCenter.default.addObserver(self, selector: #selector(self.genArray), name: NSNotification.Name(rawValue: "SavedResourceChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: NSNotification.Name(rawValue: "ResourceAsyncFinished"), object: nil)
        
        
        alert.addTextField {
            (textField) in
            textField.text = ""
        }
        
        collectionView.refreshControl = refresh;
        refresh.addTarget(self, action: #selector(self.reload(_:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "Fetching resources")
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak alert] (_) in
            let textField = alert?.textFields![0]
            if(textField != nil && textField!.text != "" )
            {
                self.inputString = textField!.text as! String
                print(self.inputString)
                self.addGroup()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
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
        
        let groupCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ResourceGroup> {
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
        collectionView.dragDelegate = self;
        collectionView.dropDelegate = self;
        collectionView.dragInteractionEnabled = true;
        
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func reload(_ sender: Any) {
        if(finishedRefreshing)
        {
            finishedRefreshing = false;
        self.genArray();
        }
        refresh.endRefreshing();
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
            
            var tempGroup = ResourceGroup(name:group.name,resources: [])
            for res in group.resources
            {
                print("--------asdasd------- " + res.name)
                tempGroup.resources.append(res.hashableResource)
            }
            groups.append(tempGroup)
            print(tempGroup.name + " added to group array")
        }
        
        
        let resourceCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ResourceHashable> {
            (cell, indexPath, resource) in
            
            var contents = cell.defaultContentConfiguration()
            contents.text = resource.name
            contents.image = UIImage(systemName: "bolt.fill")
            
            cell.contentConfiguration = contents
        }
        
        let groupCellReg = UICollectionView.CellRegistration<UICollectionViewListCell, ResourceGroup> {
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
                self.finishedRefreshing = true;

            }
            else
            {

                for doc in docsSnap!.documents {
                    
                    let path = doc.data()["docRef"] as! String
                    self.db.document(path).getDocument() { docs, error in
                        if let error = error {
                            
                        }
                        else{
                            if(docs != nil && docs!.exists)
                            {
                                
                        
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
                            var tempGroup = ResourceGroupUnhashed(name:tempName,resources:[])
                            tempGroup.resources.append(newResource)
                            self.groupsUnhashed.append(tempGroup)
                            
                        }
                        
                        
                    }
                                
                                
                        }
                        else
                            {
                                doc.reference.delete()
                            }
                            
                        }
                }
                            }
                    self.finishedRefreshing = true

                
                
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
    
    func addGroup() {
        if(self.inputString != "")
        {
            print("adding group")
            let newGroup = ResourceGroupUnhashed(name: self.inputString, resources: [])
            
            self.groupsUnhashed.append(newGroup)
            self.update()
        }
        else
        {
            print("input string blank")
        }
    }


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
        // deselects item, so it does not stay grey
        collectionView.deselectItem(at: indexPath as IndexPath, animated: true)

        return
    }
    
    
    
}

@available(iOS 14.0, *)
extension ResourceViewCollectionVC: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let selectedResource = data.itemIdentifier(for:indexPath)
        
        switch selectedResource {
        case .resource(let resource):
            self.selectedResource = resource
            break;
        default:
            break;
            
        }
        
        let item = self.selectedResource
        let itemProvider = NSItemProvider(object: item.name as NSItemProviderWriting)
        let draggedItem = UIDragItem(itemProvider: itemProvider)
        draggedItem.localObject = item
        print("Dragging " + item.name);
        return [draggedItem]
    }
}
@available(iOS 14.0, *)
extension ResourceViewCollectionVC: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationPath: IndexPath
        
        var destinationItem : ListType;
        print("dragging here");
        if let indexPath = coordinator.destinationIndexPath {
            destinationPath = indexPath
            destinationItem = data.itemIdentifier(for: coordinator.destinationIndexPath!)!;
            
            switch destinationItem {
            case .group(let group):
                print("group")
                let name = group.name;
                let usersRef = db.collection("users")
                let currUserRef = usersRef.document(Constants.User.sharedInstance.userID)
                let savedResourceRef = currUserRef.collection("SAVEDRESOURCES")
                savedResourceRef.getDocuments() {
                    docsSnap, error in
                    if let error = error {
                        print("Error getting saved resources while dragging. \(error)")
                    }
                    else
                    {
                        for doc in docsSnap!.documents {
                            if(doc.data()["docRef"] as! String == self.selectedResource.path)
                            {
                                doc.reference.setData(["groupName": name], merge:true)
                                self.genArray()
                                return
                            }
                        }
                    
                    }
                
            }
                break
            case .resource(let resource):
                print("resource");
                let usersRef = db.collection("users")
                var groupName = "";
                let currUserRef = usersRef.document(Constants.User.sharedInstance.userID)
                let savedResourceRef = currUserRef.collection("SAVEDRESOURCES")
                savedResourceRef.getDocuments() {
                    docsSnap, error in
                    if let error = error {
                        print("Error getting saved resources while dragging. \(error)")
                    }
                    else
                    {
                        for doc in docsSnap!.documents {
                            
                            if(doc.data()["docRef"] as! String == resource.path)
                            {
                                groupName = doc.data()["groupName"] as! String
                            }
                        }
                        for doc in docsSnap!.documents {
                            
                            if(doc.data()["docRef"] as! String == self.selectedResource.path)
                            {
                                doc.reference.setData(["groupName": groupName], merge:true)
                                self.genArray()
                                return
                            }
                        }
                    
                    }
                
            }
                
                break
            
        }
            
        } else
        {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationPath = IndexPath(item: row-1, section: 0)
            print("none")
            
            let usersRef = db.collection("users")
            let currUserRef = usersRef.document(Constants.User.sharedInstance.userID)
            let savedResourceRef = currUserRef.collection("SAVEDRESOURCES")
            savedResourceRef.getDocuments() {
                docsSnap, error in
                if let error = error {
                    print("Error getting saved resources while dragging. \(error)")
                }
                else
                {
                    for doc in docsSnap!.documents {
                        if(doc.data()["docRef"] as! String == self.selectedResource.path)
                        {
                            doc.reference.setData(["groupName": ""], merge:true)
                            self.genArray()
                            return
                        }
                    }
                
                }
            
        }
        }
        
        
    
    
}
}


