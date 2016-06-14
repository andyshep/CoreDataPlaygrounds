//: Playground - noun: a place where people can play

import Cocoa
import CoreData
import PlaygroundSupport

enum CoreDataError: ErrorProtocol {
    case modelNotFound
    case modelNotCreated
}

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

func insertObjectsIntoContext(_ context: NSManagedObjectContext) throws {
    
    let names = ["apricot", "nectarine", "grapefruit", "papaya", "peach", "orange"]
    
    for name in names {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Fruit", into: context)
        
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
        arrayController.sortDescriptors = [SortDescriptor(key: "name", ascending: true)]
        
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

column.bind(NSValueBinding, to: dataSource.arrayController, withKeyPath: "arrangedObjects.name", options: nil)
try dataSource.arrayController.fetch(with: nil, merge: false)

PlaygroundPage.current.liveView = tableView
