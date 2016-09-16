//import Foundation
//import UIKit
//import CoreData
//
//public class DataSource: NSObject {
//    public let context: NSManagedObjectContext
//    
//    public weak var tableView: UITableView? {
//        didSet {
//            tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//            tableView!.dataSource = self
//            
//            do {
//                try fetchedResultsController.performFetch()
//            }
//            catch {
//                print("Error executing fetch: \(error).")
//            }
//            
//            self.tableView!.reloadData()
//        }
//    }
//    
//    public init(context: NSManagedObjectContext) {
//        self.context = context
//        super.init()
//    }
//    
//    public lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
//        fetchRequest.sortDescriptors = [SortDescriptor(key: "timestamp", ascending: true)]
//        
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
//        frc.delegate = self
//        
//        return frc
//    }()
//}
//
//extension DataSource: UITableViewDataSource {
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.fetchedResultsController.fetchedObjects?.count ?? 0
//    }
//    
//    @objc public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        
//        let event = self.fetchedResultsController.fetchedObjects?[(indexPath as NSIndexPath).row]
//        guard let timestamp = event?.value(forKey: "timestamp") as? Date else { fatalError() }
//        cell.textLabel?.text = timestamp.description
//        
//        return cell
//    }
//}
//
//extension DataSource: NSFetchedResultsControllerDelegate {
//    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView?.beginUpdates()
//    }
//    
//    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView?.insertRows(at: [newIndexPath!], with: .fade)
//        case .delete:
//            tableView?.deleteRows(at: [indexPath!], with: .fade)
//        case .update:
//            break
//        case .move:
//            tableView?.deleteRows(at: [indexPath!], with: .fade)
//            tableView?.insertRows(at: [newIndexPath!], with: .fade)
//        }
//    }
//    
//    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView?.endUpdates()
//    }
//}
