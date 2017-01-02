//
//  StudentTableViewCell.swift
//  MyFirstApp
//
//  Created by admin on 01/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit

class GroceryListTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
