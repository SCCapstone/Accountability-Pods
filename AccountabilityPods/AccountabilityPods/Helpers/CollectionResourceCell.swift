//
//  CollectionResourceCell.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/4/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit

class CollectionResourceCell: UICollectionViewCell {
    @IBOutlet weak var resourceName: UILabel!
    
    func setResource(resource: Resource)
    {
        self.resourceName.text = resource.name
    }
    
}
