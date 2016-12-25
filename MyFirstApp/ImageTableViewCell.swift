//
//  ImageTableViewCell.swift
//  MyFirstApp
//
//  Created by admin on 25/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var imagez: UIImageView!
    @IBOutlet weak var pleaseWait: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func showSpinner() {
        imagez.isHidden = true
        pleaseWait.isHidden = false
        pleaseWait.startAnimating()
    }
    
    public func hideSpinner() {
        pleaseWait.stopAnimating()
        pleaseWait.isHidden = true
        imagez.isHidden = false
    }
}
