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

    var whenListAdded: ((_: Int) -> Void)?
    var whenListDeleted: ((_: Int?) -> Void)?

    init(userKey: NSString) {
        groupsDb = UserGroupsDB(userKey: userKey)
    }

    func observeLists(whenListAdded: @escaping (_: Int) -> Void, whenListDeleted: @escaping(_: Int?) -> Void) {
        self.whenListAdded = whenListAdded
        self.whenListDeleted = whenListDeleted
        groupsDb!.observeUserGroupsAddition(whenGroupAdded: groupAdded)
        groupsDb!.observeUserGroupsDeletion(whenGroupDeleted: groupDeleted)
    }

    private func groupAdded(groupIndex: Int) {
        let group = groupsDb!.getGroup(row: groupIndex)

        let db = GroceryListsByGroupDB(groupKey: group!.key)
        listsDb.append(db)

        db.observeListsAddition(whenAdded: listAdded)
        db.observeListsDeletion(whenDeleted: listDeleted)
    }

    private func listAdded(addedList: GroceryList) {
        lists.append(addedList)
        whenListAdded!(lists.count - 1)
    }

    private func listDeleted(deletedList: GroceryList) {
        let deletedListIndex = lists.index(where: { $0.id == deletedList.id })!
        lists.remove(at: deletedListIndex)
        whenListDeleted!(deletedListIndex)
    }

    private func groupDeleted(_: Int, deletedGroup: Group) {
        removeGroupObserver(groupKey: deletedGroup.key)
        removeGroupLists(groupKey: deletedGroup.key)
        whenListDeleted!(nil)
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

    func getGroceryList(row: Int) -> GroceryList? {
        if (row < getListsCount()) {
            return lists[row]
        }

        return nil
    }
}