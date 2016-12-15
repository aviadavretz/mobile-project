//
//  CustomTabBarController.swift
//  MyFirstApp
//
//  Created by Naveh Ohana on 07/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiddleButton()
    }
    
    // MARK: - Setups
    func setupMiddleButton() {
        let cameraButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        var cameraButtonFrame = cameraButton.frame
        cameraButtonFrame.origin.y = view.bounds.height - cameraButtonFrame.height
        cameraButtonFrame.origin.x = view.bounds.width/2 - cameraButtonFrame.size.width/2
        cameraButton.frame = cameraButtonFrame
        
        cameraButton.backgroundColor = UIColor(red: 10/255, green: 100/255, blue: 250/255, alpha: 0.7)
        cameraButton.layer.cornerRadius = cameraButtonFrame.height/2
        view.addSubview(cameraButton)
        
        cameraButton.setImage(UIImage(named: "camera.png"), for: .normal)
        cameraButton.setImage(UIImage(named: "camera2.png"), for: .highlighted)
        
        cameraButton.addTarget(self, action: #selector(cameraAction(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    @objc private func cameraAction(sender: UIButton) {
        selectedIndex = 1
    }
}
