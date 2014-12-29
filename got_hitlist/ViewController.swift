//
//  ViewController.swift
//  got_hitlist
//
//  Created by Kevin on 2014-11-21.
//  Copyright (c) 2014 the.baratheon. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    // Table's view model
    var people = [NSManagedObject]()
    
    // SAVING TO CORE DATA
    func saveName(name: String) {
        // To save a new managedObject, we need to write it to a managedObjectContext, in this case the default one provided by our CoreData settings.
        // Note: Some of the code here—getting the managed object context and entity¬—could be done just once in your own init or viewDidLoad and then reused later. For simplicity, you’re doing it all at once in one method.
        
        //1: there exists a managedObjectContext in the application's delegate since we initialized the app with CoreData.  Thus in this step we retrieve this default managedObjectContext and assign it to managedContext for later use. BEFORE YOU CAN DO ANYTHING IN COREDATA, you need this managedObjectContext
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //2: next, we define the new managed object to which we can write our changes, such that they can be then written to the managedObjectContext, which can then be "written to disk". Thus in this step we define the variable 'entity' as the entity (table) that corresponds to "Person" entity (table) in our data model and we map them together with the 'NSEntityDescription' since otherwise NSManagedObject's are free-form and have variable values/types. thus we create a new managed object "person" and insert into our managedObjectContext, which we named 'managedContext' earlier
        
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        // init(entity:insertIntoManagedObjectContext:)
        
        //3: make modifications to the freshly defined managedObject 'person' with the information of interest: in this case we are trying to save a name. thus we modify the managedObject's name attribute using key-value coding (KVC)- in this case, the key that exactly corresponds to the KVC key in our data model's "person" entity (table). in this case 'name'
        
        person.setValue(name, forKey: "name")
        
        //4: now save these modifications by calling save on our managedContext. the save method always points to an error to throw if the save should go awry. thus we define the error and have an error statement in place for debugging down the road
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        //5: finally, insert the managedObject into the 'people' array (as defined in line 16) so that the data persists
        people.append(person)
    }

    @IBAction func addName(sender: AnyObject) {
        var alert = UIAlertController(title: "New Name",
            message: "Add a new name",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction?) -> Void in
                
                let textField = alert.textFields![0] as UITextField
                println("\(textField.text)")
                self.saveName(textField.text)
                // self.names.append(textField.text)
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction?) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "\"The List\""
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
                as UITableViewCell
            
            let person = people[indexPath.row]
            cell.textLabel?.text = person.valueForKey("name") as String?
            return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // FETCH FROM CORE DATA
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1 Just like before, pull up an instance of the default AppDelegate (which belongs to the application) and grab its managedObjectContext
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        
        //2 Next, we fetch from the NSManagedObjectContext
        // Setting a fetch request’s entity property, or alternatively initializing it with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.

        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        //3
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            people = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }


}

