//
//  ShoppingListTableViewController.swift
//  Shopper
//
//  Created by student on 3/31/16.
//  Copyright © 2016 Josh. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var selectedShoppingList: ShoppingList?
    
    var shoppingListItems = [ShoppingListItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addShoppingListItem:"), UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "selectFilter:"),
            UIBarButtonItem(title: "Sort", style: .Plain, target: self, action: "selectSort:")
        ]


        reloadData()
    
        var totalCost = 0.0
        
        for list in shoppingListItems {
            totalCost += Double(list.price) * Double(list.quantity)
        }
        
        if let selectedShoppingList = selectedShoppingList {
            title = selectedShoppingList.name + String(format: " $%.2f", totalCost)
        } else {
            title = "Shopping List Detail"
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData (nameFilter: String? = nil, sortDescriptor: String? = nil) {
        
        
        let fetchRequest = NSFetchRequest(entityName: "ShoppingListItem")
        
        //create a filter for the shopping list
        let listPredicate = NSPredicate(format: "shoppingList =[c] %@", selectedShoppingList!)
        
        
        // crete a second filter for the shopping list
        //setup a predicate in order to filter the shopping lists
        if let nameFilter = nameFilter {//                  c yields case insensitive filter
            let namePredicate = NSPredicate(format: "name =[c] %@", nameFilter)
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [listPredicate, namePredicate])
            
            fetchRequest.predicate = compoundPredicate
        }
        else { fetchRequest.predicate = listPredicate
        }
        
        if let sortDescriptor = sortDescriptor {
            let sort = NSSortDescriptor(key: sortDescriptor, ascending: true)
            fetchRequest.sortDescriptors = [sort]
        }
        
        //if let selectedShoppingList = selectedShoppingList {
          //  if let listItems = selectedShoppingList.items?.allObjects as? [ShoppingListItem] {
          //      shoppingListItems = listItems
           // }
       // }
        //tableView.reloadData()
        
        do {
            
            //returns object which is casted to array shopping list and is stored in results
            if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as?
                [ShoppingListItem] {
                    shoppingListItems = results
                    //not recursive reload data call, this is the call to reload data in the tableview..tableview is an actual control in the storyboard
                    tableView.reloadData()
            }
            
        } catch {
            fatalError("There was an error fetching shopping lists!")
            
        }
    }
    
    func selectSort(sender: AnyObject?) {
        
        let sheet = UIAlertController(title: "Sort", message: "Shopping List Items", preferredStyle: .ActionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {(action) -> Void in }))
        
        sheet.addAction(UIAlertAction(title: "By Name", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "name")
        }))
        sheet.addAction(UIAlertAction(title: "By Price", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "price")
        }))
        
        sheet.addAction(UIAlertAction(title: "By Quantity", style: .Default, handler: {(action) -> Void in
            self.reloadData(nil, sortDescriptor: "quantity")
        }))
        
        presentViewController(sheet, animated: true, completion: nil)
        
        
    }
    
    func selectFilter(sender: AnyObject?) {
        let alert = UIAlertController(title: "Filter", message: "Shopping List Items", preferredStyle: .Alert)
        
        let filterAction = UIAlertAction(title: "Filter", style: .Default) {
            (action) -> Void in
            
            if let nameTextField = alert.textFields?[0], name = nameTextField.text {
                self.reloadData(name)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action) -> Void in
            self.reloadData()
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Name"
        }
        
        alert.addAction(filterAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    
    func addShoppingListItem(sender: AnyObject?) {
        
        let alert = UIAlertController (title: "Add", message: "Shopping List Item", preferredStyle: .Alert)
        
        let addAction = UIAlertAction(title: "Add", style: .Default) { (action) -> Void in
            
            if let nameTextField = alert.textFields?[0], priceTextField = alert.textFields?[1], quantityTextField = alert.textFields?[2], shoppingListItemEntity = NSEntityDescription.entityForName("ShoppingListItem", inManagedObjectContext: self.managedObjectContext), name = nameTextField.text, price = priceTextField.text, quantity = quantityTextField.text {
                
                
                let newShoppingListItem = ShoppingListItem(entity: shoppingListItemEntity, insertIntoManagedObjectContext: self.managedObjectContext)
                
                newShoppingListItem.name = name
                newShoppingListItem.quantity = Int(quantity)!
                newShoppingListItem.price = Double(price)!
                newShoppingListItem.purchased = false
                newShoppingListItem.shoppingList = self.selectedShoppingList
                
                do {
                    try self.managedObjectContext.save()
                    self.viewDidLoad()
                } catch {
                    print("Error saving the managed object context!")
                }
                self.reloadData()
            }
        }
        
        addAction.enabled = false
    
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) -> Void in
            
        }
        
        var nameTextField: UITextField?
        var priceTextField: UITextField?
        var quantityTextField: UITextField?

        
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Name"
            //initialize the name text field to  the textfield w/in the code block
            nameTextField = textField
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in addAction.enabled = (nameTextField!.text != "" && priceTextField!.text != "" && quantityTextField!.text != "")
            }
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Price"
            priceTextField = textField
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in addAction.enabled = (nameTextField!.text != "" && priceTextField!.text != "" && quantityTextField!.text != "")
            }
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Quantity"
            quantityTextField = textField
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in addAction.enabled = (nameTextField!.text != "" && priceTextField!.text != "" && quantityTextField!.text != "")
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    func shoppingListDoneNotification () {
        
        var done = true
        
        for list in shoppingListItems {
            if list.purchased == false {
                done = false
            }
        }
        
        if done == true {
            //getting the current date
            let theDate = NSDate()
            
            //getting the date component and setting the seconds property to 10 seconds
            let dateComp = NSDateComponents()
            dateComp.second = 10
            
            //making a calender
            let cal = NSCalendar.currentCalendar()
            
            //adding 10 seconds to the current date...basically saying "we want the alert to go off 10 seconds from the current date
            let fireDate:NSDate = cal.dateByAddingComponents(dateComp, toDate: theDate, options: NSCalendarOptions.MatchFirst)!
            
            //initializing a notification
            let notification:UILocalNotification = UILocalNotification()
            
            //get the name of the shopping ist that has just been completed and storing it in title
            if let selectedShoppingList = selectedShoppingList {
                title = selectedShoppingList.name
            }
            
            //we want the body propertiy of out notification to contain the name of the completed shopping list and the word completed
            notification.alertBody = title! + " completed"
            
            
            //set the fire date proeprty of the ntifcation equal to our fire date variable whic his 10 secs after current date
            notification.fireDate=fireDate
            
            //post the notification
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingListItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingListItemCell", forIndexPath: indexPath)

        // Configure the cell...
        
        //gotten the first element in the shoppinglistitmes array
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        let sQantity = String(shoppingListItem.quantity)
        let sPrice = String(shoppingListItem.price)
        let purchased = shoppingListItem.purchased
        
        cell.textLabel?.text = shoppingListItem.name
        cell.detailTextLabel?.text = sQantity + " " + sPrice
        
        if purchased == false {
            cell.accessoryType = .None
        } else {
            cell.accessoryType = .Checkmark
            
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingListItemCell", forIndexPath: indexPath)
        
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        let sQuantity = String(shoppingListItem.quantity)
        let sPrice = String(shoppingListItem.price)
        
        if shoppingListItem.purchased == true {
            cell.accessoryType = .None
            shoppingListItem.purchased = false
        } else {
            cell.accessoryType = .Checkmark
            shoppingListItem.purchased = true
        }
        
        cell.textLabel?.text = shoppingListItem.name
        cell.detailTextLabel?.text = sQuantity + " " + sPrice
        
        do{
            try self.managedObjectContext.save()
            self.viewDidLoad()
        } catch {
            print("Error saving the managed object context!")
        }
        
        
        reloadData()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        shoppingListDoneNotification()
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true//leave true to be able to delete a row
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            //check if user is deleting a row
            let item = shoppingListItems[indexPath.row]
            
            managedObjectContext.deleteObject(item)
            
            do {
                try self.managedObjectContext.save()
                self.viewDidLoad()
            } catch {
                print("Error saving the managed object context!")
            }
            reloadData()
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
