//
//  ShoppingListItem+CoreDataProperties.swift
//  Shopper
//
//  Created by student on 3/22/16.
//  Copyright © 2016 Josh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ShoppingListItem {

    @NSManaged var name: String
    @NSManaged var price: NSNumber
    @NSManaged var purchased: NSNumber
    @NSManaged var quantity: NSNumber
    //a shopping list item is relted to a ...
    @NSManaged var shoppingList: ShoppingList?

}
