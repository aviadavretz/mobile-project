//
//  RoundedImageView.swift
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
        
        self.layer.borderWidth = self.frame.size.width / 250
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.size.width / 20
        self.clipsToBounds = true
    }
}
