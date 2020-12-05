//
//  SavedResourcesCollectionVC.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class SavedResourcesCollectionVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let user = Constants.User.sharedInstance.userID
    let db = Firestore.firestore()
    var folders: [Folder] = []
    var resources: [Resource] = []
    @IBOutlet weak var nameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        genFolderArray()
        genResourceArray()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped(_:)))
        self.collectionView.addGestureRecognizer(tap)
        self.collectionView.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "OnGroupCreation"), object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func reload()
    {
        print("Notified")
        self.resources = []
        self.folders = []
        self.genFolderArray()
        self.genResourceArray()
        collectionView.reloadData()
        
    }
    
    @objc func cellTapped(_ sender: UITapGestureRecognizer)
    {
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView))
        {
            if collectionView.cellForItem(at: indexPath)?.reuseIdentifier == "CollectionResourceCell"
            {
                performSegue(withIdentifier: "showResourceSegue", sender: indexPath)
            }
            else
            {
                performSegue(withIdentifier: "showFolderSegue", sender: indexPath)
            }
                
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResourceSegue"
        {
            let index = sender as? NSIndexPath
            let dest = segue.destination as! ResourceDisplayVC
            dest.resource = self.resources[index!.row - self.folders.count]
        }
        else
        {
            let index = sender as? NSIndexPath
            let dest = segue.destination as! GroupViewVC
            
            return
        }
    }
    
    func genFolderArray()
    {
        db.collection("users").document(self.user).collection("GROUPEDRESOURCES").getDocuments() {
            docRefs, err in
            if let err = err {
                print("Error checking group resources. \(err)")
            }
            else
            {
                
                for doc in docRefs!.documents {
                    let tempFolder = Folder()
                    print("I'm generating!")
                    tempFolder.readData(database: self.db, path: doc.reference.path , collection: self.collectionView)
                    self.folders.append(tempFolder)
                    
                }
                self.collectionView.reloadData()
            }
        }
    }
    func genResourceArray()
    {
        db.collection("users").document(self.user).collection("SAVEDRESOURCES").getDocuments()
        {
            docRefs, err in
            if let err = err {
                print("Error getting saved resources. \(err)")
                
            }
            else
            {
                for doc in docRefs!.documents {
                    let tempResource = Resource()
                    tempResource.readData(database: self.db, path: doc.data()["docRef"] as! String, collection: self.collectionView)
                    self.resources.append(tempResource)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func createNewGroup(_ sender: Any) {
        
        let nameText = self.nameField.text
        
        if(nameText == nil)
        {
            return
        }
        
        db.collection("users").document(user).collection("GROUPEDRESOURCES").addDocument(data: ["folderName" : nameText!])
        {
            err in
            if let err = err
            {
                print(err)
            }
            else
            {
                self.collectionView.reloadData()
            }
            
        }
        
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

extension SavedResourcesCollectionVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(folders.count + resources.count)
        return folders.count + resources.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row >= folders.count
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionResourceCell", for:indexPath) as! CollectionResourceCell
            cell.setResource(resource: resources[indexPath.row - folders.count])
            print("Yope")
            return cell
            
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupFolderCell", for:indexPath) as! GroupFolderCell
            cell.setFolder(folder: folders[indexPath.row])
            print("Yeep")
            return cell
        }
    }
    
    
    
    
}
