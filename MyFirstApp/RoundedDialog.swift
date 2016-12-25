//
//  RoundedDialog.swift
//  MyFirstApp
//
//  Created by admin on 25/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class RoundedDialog: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 2
        self.layer.cornerRadius = self.frame.size.width / 5
        self.layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
    }
}
