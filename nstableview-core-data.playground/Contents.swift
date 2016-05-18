//: Playground - noun: a place where people can play

import Cocoa
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
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    lazy var arrayController: NSArrayController = {
        let arrayController = NSArrayController()
        arrayController.managedObjectContext = self.context
        arrayController.entityName = "Fruit"
        arrayController.automaticallyPreparesContent = false
        arrayController.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return arrayController
    }()
}

let column = NSTableColumn(identifier: "Name")
column.width = 300

let tableView = NSTableView(frame: CGRect(x: 0, y: 0, width: 230, height: 300))
tableView.addTableColumn(column)
tableView.usesAlternatingRowBackgroundColors = true

let context = try createManagedObjectContext()
try insertObjectsIntoContext(context)

let dataSource = DataSource(context: context)

column.bind(NSValueBinding, toObject: dataSource.arrayController, withKeyPath: "arrangedObjects.name", options: nil)
try dataSource.arrayController.fetchWithRequest(nil, merge: false)

XCPlaygroundPage.currentPage.liveView = tableView