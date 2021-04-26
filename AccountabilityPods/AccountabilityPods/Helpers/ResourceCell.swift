//
//  ResourceCell.swift
//  AccountabilityPods
//
//  Created by duncan evans on 12/3/20.
//  Copyright © 2020 CapstoneGroup. All rights reserved.
//
// Description: Class for a cell in any table that has resources (home, own resources, etc.)

import UIKit
class ResourceCell: UITableViewCell {
    /// The name of the resource in the cell
    @IBOutlet weak var resourceName: UILabel!
    /// The description of the resource in the cell
    @IBOutlet weak var resourceDesc: UILabel!
    
    /// Sets the text in the cell from data in a given resource obejct
    ///
    /// - Parameter resource: the resource object displayed in the cell (passed from table controller)
    func setResource(resource: Resource)
    {
        self.resourceName.text = resource.name
        self.resourceDesc.text = resource.desc
        resourceDesc.sizeToFit()
    }
}
