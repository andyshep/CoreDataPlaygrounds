import Foundation
import UIKit
import CoreData

public class DataSource: NSObject {
    public let context: NSManagedObjectContext
    
    public weak var tableView: UITableView? {
        didSet {
            tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView!.dataSource = self
            
            do {
                try fetchedResultsController.performFetch()
            }
            catch {
                print("Error executing fetch: \(error).")
            }
            
            self.tableView!.reloadData()
        }
    }
    
    public init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    public lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
}

extension DataSource: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        guard let event = self.fetchedResultsController.fetchedObjects?[indexPath.row] as? NSManagedObject else { fatalError() }
        guard let timestamp = event.valueForKey("timestamp") as? NSDate else { fatalError() }
        cell.textLabel?.text = timestamp.description
        
        return cell
    }
}

extension DataSource: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.beginUpdates()
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
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
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.endUpdates()
    }
}