//
// Created by admin on 27/12/2016.
// Copyright (c) 2016 Naveh Ohana. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserGroceryListsDB {
    var lists = Array<GroceryList>()
    var groupsDb: UserGroupsDB?
    var listsDb = Array<GroceryListsByGroupDB>()

    var whenListAddedAtIndex: ((_: Int) -> Void)?
    var whenListDeletedAtIndex: ((_: Int?) -> Void)?

    init(userKey: NSString) {
        groupsDb = UserGroupsDB(userKey: userKey)
    }

    func observeLists(whenListAddedAtIndex: @escaping (_: Int) -> Void, whenListDeletedAtIndex: @escaping(_: Int?) -> Void) {
        self.whenListAddedAtIndex = whenListAddedAtIndex
        self.whenListDeletedAtIndex = whenListDeletedAtIndex
        groupsDb!.observeUserGroupsAddition(whenGroupAdded: groupAdded)
        groupsDb!.observeUserGroupsDeletion(whenGroupDeleted: groupDeleted)
    }

    private func groupAdded(groupIndex: Int) {
        let group = groupsDb!.getGroup(row: groupIndex)

        // Make sure we didn't already add this group's grocery lists (Could happen when UserGroupsDB resets).
        if (listsDb.index(where: {$0.groupKey == group!.key}) == nil) {
            let db = GroceryListsByGroupDB(groupKey: group!.key)
            listsDb.append(db)

            db.observeListsAddition(whenAdded: listAdded)
            db.observeListsDeletion(whenDeleted: listDeleted)
        }
    }

    private func listAdded(addedList: GroceryList) {
        lists.append(addedList)
        whenListAddedAtIndex!(lists.count - 1)
    }

    private func listDeleted(deletedList: GroceryList) {
        let deletedListIndex = lists.index(where: { $0.id == deletedList.id })!
        lists.remove(at: deletedListIndex)
        whenListDeletedAtIndex!(deletedListIndex)
    }

    private func groupDeleted(_: Int, deletedGroup: Group) {
        removeGroupObserver(groupKey: deletedGroup.key)
        removeGroupLists(groupKey: deletedGroup.key)
        whenListDeletedAtIndex!(nil)
    }

    private func removeGroupObserver(groupKey: NSString) {
        guard let dbIndex = listsDb.index(where: { $0.groupKey == groupKey }) else { return }

        listsDb[dbIndex].removeObservers()
    }

    private func removeGroupLists(groupKey: NSString) {
        lists = lists.filter({ $0.groupKey != groupKey })
    }

    func removeObservers() {
        groupsDb!.removeObservers()
        listsDb.forEach({ $0.removeObservers() })
    }

    func getListsCount() -> Int {
        return lists.count
    }
    
    func doesUserHaveGroup() -> Bool {
        return groupsDb!.getGroupsCount() > 0
    }

    func getGroceryList(row: Int) -> GroceryList? {
        if (row < getListsCount()) {
            return lists[row]
        }

        return nil
    }
}
