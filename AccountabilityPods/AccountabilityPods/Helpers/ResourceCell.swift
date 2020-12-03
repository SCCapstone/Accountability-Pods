//
//  ResourceCell.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//

import UIKit
class ResourceCell: UITableViewCell {

    @IBOutlet weak var resourceName: UILabel!
    @IBOutlet weak var resourceDesc: UILabel!
    
    func setResource(resource: Resource)
    {
        self.resourceName.text = resource.name
        self.resourceDesc.text = resource.desc
    }
}
