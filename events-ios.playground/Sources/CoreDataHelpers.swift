import CoreData

public enum CoreDataError: Error {
    case modelNotFound
    case modelNotCreated
}

public func createManagedObjectContext() throws -> NSManagedObjectContext {
    guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "mom") else {
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
