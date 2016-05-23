//: ## A UITableView backed by Core Data
//:
//: In this playground, we'll display a UITableView with a simple list of names, using Core Data and a Fetched Results Controller.

//: Here's a diagram of the data model. There is a one entity named `Fruit` with a single `String` attribute for the name.

//:     +---------------+
//:     | Fruit         |
//:     |---------------|
//:     | name          |
//:     |               |
//:     +---------------+

//: Unlike with the previous playground, this time the core data model defined externally, using an `momd` file.

//: First import the necessary frameworks.

import UIKit
import CoreData
import XCPlayground

//: Next define an `ErrorType` to use later on, when handling Core Data errors.

enum CoreDataError: ErrorType {
    case ModelNotFound
    case ModelNotCreated
}

//: To build the Core Data stack we'll use a `createManagedObjectContext()` function that returns an `NSManagedObjectContext` or throws a `CoreDataError` if something went wrong. Creating the managed object context is fairly straightforward.
/*:
 1. Find the URL for the `Model.momd` resource in the playground or throw a .ModelNotFound error
 2. Load the model using the URL or throw a .ModelNotCreated error
 3. Create a Persistent Store Coordinator using the model
 4. Try adding a Persistent Store to the Coordinator
 5. Create a Managed Object Context and assign the coordinator.
*/

func createManagedObjectContext() throws -> NSManagedObjectContext {
    guard let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd") else {
        throw CoreDataError.ModelNotFound
    }
    
    guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
        throw CoreDataError.ModelNotCreated
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    
    let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    
    return context
}

//: One important point is that the model is loaded from a `momd` file, which is part of the Playground resources. In a full blown Xcode project, a `momd` file is typically compiled from a `xcdatamodel`. But this doesn't happen inside a playground. Instead, the commmand line tool `momc` was used to compile the `xcdatamodel` and place the results `momd` inside this playground.

func insertObjectsIntoContext(context: NSManagedObjectContext) throws {
    let names = ["apricot", "nectarine", "grapefruit", "papaya", "peach", "orange"]
    
    for name in names {
        let entity = NSEntityDescription.insertNewObjectForEntityForName("Fruit", inManagedObjectContext: context)
        entity.setValue(name, forKey: "name")
    }
    
    try context.save()
}

//: Next create a data source object

class DataSource: NSObject {
    let context: NSManagedObjectContext
    
    weak var tableView: UITableView? {
        didSet {
            tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView!.dataSource = self
            
            do {
                try fetchedResultsController.performFetch()
            }
            catch {
                print("Error in the fetched results controller: \(error).")
            }
            
            self.tableView!.reloadData()
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Fruit")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
}

//: Using an extension, conform to the `UITableViewDataSource` protocol

extension DataSource: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        guard let fruit = self.fetchedResultsController.fetchedObjects?[indexPath.row] as? NSManagedObject else { fatalError() }
        guard let name = fruit.valueForKey("name") as? String else { fatalError() }
        cell.textLabel?.text = name
        
        return cell
    }
}

//: Similarly, conform to the `NSFetchedResultsControllerDelegate` through an extension.

extension DataSource: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            break
        case .Move:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.endUpdates()
    }
}

//: A simple view controller is used to display a table view.

class ViewController: UIViewController {
    var tableView: UITableView {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        return tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
    }
}

let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
XCPlaygroundPage.currentPage.liveView = tableView

do {
    let context = try createManagedObjectContext()
    try insertObjectsIntoContext(context)
    
    let dataSource = DataSource(context: context)
    dataSource.tableView = tableView
} catch {
    print("error: \(error)")
}
