//
//  RoundedImage.swift
//  MyFirstApp
//
//  Created by admin on 25/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class RoundedImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0
        self.layer.cornerRadius = self.frame.size.width / 4.5
        self.clipsToBounds = true
    }
}
