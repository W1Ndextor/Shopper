//
//  ShopperTableViewController.swift
//  Shopper
//
//  Created by student on 3/22/16.
//  Copyright © 2016 Josh. All rights reserved.
//

import UIKit
import CoreData

class ShopperTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    //setting up array of shoppingList (managed) objects
    var shoppingLists = [ShoppingList] ()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addShoppingList:")
        
        reloadData()
    }
    
    // format this code appropriately, the brackets (and therefore indentation) is unorganized
    func reloadData() {
        
        //                                entity name to fetch data from
        let fetchRequest = NSFetchRequest(entityName: "ShoppingList")
        
        do {
            
            //returns object which is casted to array shopping list and is stored in results
            if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as?
                [ShoppingList] {
                shoppingLists = results
            //not recursive reload data call, this is the call to reload data in the tableview..tableview is an actual control in the storyboard
                tableView.reloadData()
            }
            
        } catch {
            fatalError("There was an error fetching shopping lists!")
        
    }
    }
    
    func addShoppingList(sender: AnyObject?){
        
        let alert = UIAlertController(title: "Add", message: "ShoppingList", preferredStyle: .Alert)
        
        let addAction =  UIAlertAction(title: "Add", style: .Default) { (action) -> Void in
            //naming text fields, then creating an instance for data insertions, then storing data input into textfields...?last step might be incorrect...
            if let nameTextField = alert.textFields?[0], storeTextField = alert.textFields?[1],
            dateTextField = alert.textFields?[2], shoppingListEntity = NSEntityDescription.entityForName("ShoppingList", inManagedObjectContext: self.managedObjectContext),name = nameTextField.text, store = storeTextField.text, date = dateTextField.text
            {
                // newShoppinglist has 3 properites name store and date, we need to take the text inpout from the laert ad populate those properties here
                let newShoppingList = ShoppingList(entity: shoppingListEntity, insertIntoManagedObjectContext: self.managedObjectContext)
                
                //storing
                newShoppingList.name = name
                newShoppingList.store = store
                newShoppingList.date = date
                
                //need do catch block because save could cause an error
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Error saving the managed object context!")
                }
                
                self.reloadData()
    }
    }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) -> Void in
            
    }
            alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Name"
        }
            alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Store"
        }
            alert.addTextFieldWithConfigurationHandler { (textField) in textField.placeholder = "Date"
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        //we want our tableview to have 1 section
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //we want to have as many rows as are needed so we count the number of shopping lists that exist in the array
        return shoppingLists.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingListCell", forIndexPath: indexPath)

        // Configure the cell...
        //the configuraton occurs for as many cells (shoppingLists) that exist
        let shoppingList = shoppingLists[indexPath.row]
        
        //maps to title
        cell.textLabel?.text = shoppingList.name
        
        //maps to subtitle
        cell.detailTextLabel?.text = shoppingList.store + " " + shoppingList.date

        return cell
    }
    
    //                                                              indexpath maps to whatever list is selcted
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let itemsTableViewController =
        storyboard?.instantiateViewControllerWithIdentifier("ShoppingListItems") as?
            //casting to a shoppinglisttableviewcontroller (with as)_____________|^|
            ShoppingListTableViewController {
                
                //getting list selected to pass it to the new screen
            let list = shoppingLists[indexPath.row]
                
                itemsTableViewController.managedObjectContext = managedObjectContext
                itemsTableViewController.selectedShoppingList = list
                
                //heres the actual segue
                navigationController?.pushViewController(itemsTableViewController, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let list = shoppingLists[indexPath.row]
            
            managedObjectContext.deleteObject(list)
            
            do {
                try self.managedObjectContext.save()
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
