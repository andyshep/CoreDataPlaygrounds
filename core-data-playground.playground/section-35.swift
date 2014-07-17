fetchRequest = NSFetchRequest(entityName: GROEntity.Neighborhood)
fetchRequest.predicate = NSPredicate(format: "name = %@", "Belltown")

results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
var managedObject = results[0] as? NSManagedObject
managedObject.description

managedObject!.setValue(1000, forKey: GROAttribute.Population)

managedObjectContext.save(&error)
managedObject = managedObjectContext.existingObjectWithID(managedObject!.objectID, error: &error)

managedObject.description