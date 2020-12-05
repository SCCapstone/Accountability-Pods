//
//  GroupViewVC.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
import Firebase
class GroupViewVC: UIViewController {
    let user = Constants.User.sharedInstance.userID
    let db = Firestore.firestore()
    @IBOutlet weak var collectionView: UICollectionView!
    var resources: [Resource] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        genResourceArray()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped(_:)))
        self.collectionView.addGestureRecognizer(tap)
        self.collectionView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
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
            dest.resource = self.resources[index!.row]
        }
        else
        {
            
            return
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GroupViewVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resources.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionResourceCell", for:indexPath) as! CollectionResourceCell
            cell.setResource(resource: resources[indexPath.row])

            return cell
            
        
    }
    
    
    
    
}
