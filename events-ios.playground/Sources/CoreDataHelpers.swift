import CoreData

public enum CoreDataError: ErrorType {
    case ModelNotFound
    case ModelNotCreated
}

public func createManagedObjectContext() throws -> NSManagedObjectContext {
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