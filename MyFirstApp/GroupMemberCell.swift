//
//  GroupMemberCell.swift
//  MyFirstApp
//
//  Created by admin on 23/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit
class GroupMemberCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imagez: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
