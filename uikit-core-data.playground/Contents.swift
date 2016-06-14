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
import PlaygroundSupport

//: Next define an `ErrorType` to use later on, when handling Core Data errors.

enum CoreDataError: ErrorProtocol {
    case modelNotFound
    case modelNotCreated
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
    guard let modelURL = Bundle.main().urlForResource("Model", withExtension: "momd") else {
        throw CoreDataError.modelNotFound
    }
    
    guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
        throw CoreDataError.modelNotCreated
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    try psc.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    
    return context
}

//: One important point is that the model is loaded from a `momd` file, which is part of the Playground resources. In a full blown Xcode project, a `momd` file is typically compiled from a `xcdatamodel`. But this doesn't happen inside a playground. Instead, the commmand line tool `momc` was used to compile the `xcdatamodel` and place the results `momd` inside this playground.

func insertObjectsIntoContext(_ context: NSManagedObjectContext) throws {
    let names = ["apricot", "nectarine", "grapefruit", "papaya", "peach", "orange"]
    
    for name in names {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Fruit", into: context)
        entity.setValue(name, forKey: "name")
    }
    
    try context.save()
}

//: Next create a data source object

class DataSource: NSObject {
    let context: NSManagedObjectContext
    
    weak var tableView: UITableView? {
        didSet {
            tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Fruit")
        fetchRequest.sortDescriptors = [SortDescriptor(key: "name", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
}

//: Using an extension, conform to the `UITableViewDataSource` protocol

extension DataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let fruit = self.fetchedResultsController.fetchedObjects?[(indexPath as NSIndexPath).row]
        guard let name = fruit?.value(forKey: "name") as? String else { fatalError() }
        cell.textLabel?.text = name
        
        return cell
    }
}

//: Similarly, conform to the `NSFetchedResultsControllerDelegate` through an extension.

extension DataSource: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView?.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            break
        case .move:
            tableView?.deleteRows(at: [indexPath!], with: .fade)
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
PlaygroundPage.current.liveView = tableView

do {
    let context = try createManagedObjectContext()
    try insertObjectsIntoContext(context)
    
    let dataSource = DataSource(context: context)
    dataSource.tableView = tableView
} catch {
    print("error: \(error)")
}
