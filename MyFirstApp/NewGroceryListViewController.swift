//
//  NewStudentViewController.swift
//  MyFirstApp
//
//  Created by admin on 01/12/2016.
//  Copyright © 2016 Naveh Ohana. All rights reserved.
//

import UIKit

class NewGroceryListViewController: UIViewController {
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var chooseGroupDialog: UIView!
    @IBOutlet weak var groupButton: UIButton!
    
    var groupId:NSString = ""

    @IBAction func SelectAllText(sender: UITextField) {
        sender.selectAll(sender)
    }
    
    // MARK: Other functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideChooseGroupDialog()
        chooseFirstGroup()
    }
    
    private func chooseFirstGroup() {
        // Fetch the user from cache
        UserFirebaseDB.sharedInstance.findUserByKey(key: CurrentFirebaseUser.sharedInstance.getId()!) { (user) in
            // TODO: Get user!.groupKeys!.first
            let firstGroupKey = user!.groupKey!
            
            // Fetch the group from cache
            GroupFirebaseDB.sharedInstance.findGroupByKey(key: firstGroupKey as String, whenFinished: { (group) in
                self.refreshGroup(group: group!)
            })
        }
    }
    
    public func refreshGroup(group: Group) {
        self.groupId = group.key
        
        groupButton.setTitle(group.title as String?, for: .normal)
    }
    
    @IBAction func showChooseGroupDialog(sender: AnyObject) {
        chooseGroupDialog.isHidden = false
    }
    
    private func hideChooseGroupDialog() {
        chooseGroupDialog.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UnwindNewList") {
            let title = titleTextView.text! as NSString
            
            let list:GroceryList = GroceryList(title: title, groupKey: groupId);
            let generatedKey = GroceryFirebaseDB.sharedInstance.addList(list: list)
            GroupFirebaseDB.sharedInstance.addListToGroup(listKey: generatedKey as NSString, forGroupKey: groupId)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backFromChooseGroupDialog(seque:UIStoryboardSegue) {
        hideChooseGroupDialog()
    }
}
