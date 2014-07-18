var moid = (results[0] as NSManagedObject).objectID
var firstObject = managedObjectContext.existingObjectWithID(moid, error: &error)

var secondContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
secondContext.persistentStoreCoordinator = persistentStoreCoordinator

var secondObject = secondContext.existingObjectWithID(moid, error: &error)

firstObject.description
secondObject.description