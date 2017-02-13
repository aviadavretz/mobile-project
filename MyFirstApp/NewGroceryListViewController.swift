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
        UserGroupsDB(userKey: AuthenticationUtilities.sharedInstance.getId()! as NSString).findFirstGroup(whenFound: refreshGroup)
    }
    
    public func refreshGroup(group: Group?) {
        if group != nil {
            self.groupId = group!.key
            groupButton.setTitle(group!.title as String?, for: .normal)
        }
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
            let generatedKey = GroceryListsDB.sharedInstance.addList(list: list)
            GroupsDB.sharedInstance.addList(toGroupKey: groupId, listKey: generatedKey as NSString)
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
