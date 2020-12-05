//
//  GroupFolderCell.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit

class GroupFolderCell: UICollectionViewCell {
    @IBOutlet weak var folderName: UILabel!
    
    func setFolder(folder: Folder)
    {
        self.folderName.text = folder.name
    }
    
}
