//
//  ItemTableViewCell.swift
//  MyFirstApp
//
//  Created by Naveh Ohana on 23/11/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit
class GroceryRequestTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imagez: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
