import UIKit
import CoreData
import XCPlayground

enum CoreDataError: ErrorType {
    case ModelNotFound
    case ModelNotCreated
}

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

func insertObjectsIntoContext(context: NSManagedObjectContext) throws {
    
    let names = ["apricot", "nectarine", "grapefruit", "papaya", "peach", "orange"]
    
    for name in names {
        let entity = NSEntityDescription.insertNewObjectForEntityForName("Fruit", inManagedObjectContext: context)
        
        entity.setValue(name, forKey: "name")
    }
    
    try context.save()
}

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
