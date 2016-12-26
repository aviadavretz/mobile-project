//
//  ChooseGroupDialogViewController.swift
//  MyFirstApp
//
//  Created by admin on 26/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class ChooseGroupDialogViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var selectedGroup: Group?
    var pickerData = Array<Group>()
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllGroupsForCurrentUser()
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    private func getAllGroupsForCurrentUser() {
        // Fetch the user from cache
        UserFirebaseDB.sharedInstance.findUserByKey(key: CurrentFirebaseUser.sharedInstance.getId()!) { (user) in
            var currentGroupKey = user!.groupKey!
            
            // TODO: Perform this for each group in user.groupKeys
            // Fetch the group from cache
            GroupFirebaseDB.sharedInstance.findGroupByKey(key: currentGroupKey as String, whenFinished: { (group) in
                // TODO: Select only the first group
                self.selectedGroup = group
                
                self.pickerData.append(group!)
            })
        }
    }
    
    // MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].title as String?
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGroup = pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row].title
        let myTitle = NSAttributedString(string: titleData as! String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.black])
        return myTitle
    }
    
    @IBAction func closeDialog() {
        // Unwind back to CameraViewController
        self.performSegue(withIdentifier: "UnwindChooseGroupDialog", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UnwindChooseGroupDialog") {
            if (selectedGroup != nil) {
                // Get a reference to the destination view controller
                let destinationVC:NewGroceryListViewController = segue.destination as! NewGroceryListViewController
                
                destinationVC.refreshGroup(group: selectedGroup!)
            }
        }
    }
}
