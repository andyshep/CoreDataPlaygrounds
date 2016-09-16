//: Playground - noun: a place where people can play

import UIKit
import CoreData
import PlaygroundSupport

let frame = CGRect(x: 0, y: 0, width: 320, height: 480)

class Something {
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

let something = Something()
let container = something.persistentContainer



//class ViewController: UIViewController {
//    
//    let dataSource: DataSource
//    
//    init(dataSource: DataSource) {
//        self.dataSource = dataSource
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.title = "Events"
//        
//        self.dataSource.tableView = self.tableView
//        self.view.addSubview(self.tableView)
//        
//        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(handleAddButton))
//        self.navigationItem.rightBarButtonItem = item
//    }
//    
//    lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: frame)
//        return tableView
//    }()
//    
//    func handleAddButton(_ sender: AnyObject) {
//        let context = self.dataSource.context
//        let entity = NSEntityDescription.insertNewObject(forEntityName: "Event", into: context)
//        entity.setValue(Date(), forKey: "timestamp")
//        
//        try! context.save()
//    }
//}
//
//let context = try createManagedObjectContext()
//let dataSource = DataSource(context: context)
//
//let viewController = ViewController(dataSource: dataSource)
//let navController = UINavigationController(rootViewController: viewController)
//
//navController.view.frame = frame
//
//PlaygroundPage.current.liveView = navController.view
