//
//  NewGroupMemberCell.swift
//  MyFirstApp
//
//  Created by admin on 27/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit
class NewGroupMemberCell: GroupMemberCell {
    
    // MARK: Properties
    @IBOutlet weak var doneButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        doneButton.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func toggleDone() {
        doneButton.isHidden = !doneButton.isHidden
    }
    
    func setTag(tag: Int) {
        doneButton.tag = tag
    }
}
