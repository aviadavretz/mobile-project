//
//  CircleImageView.swift
//  MyFirstApp
//
//  Created by admin on 25/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class CircleButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = (self.frame.size.width / 2)
        self.layer.borderColor = UIColor.white.cgColor
    }
}
