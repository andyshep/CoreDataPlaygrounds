fetchRequest = NSFetchRequest(entityName: GROEntity.Neighborhood)
fetchRequest.predicate = NSPredicate(format: "name = %@", "Belltown")

results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]
var managedObject = results[0]
managedObject.description

managedObject.setValue(1000, forKey: GROAttribute.Population)

managedObjectContext.save(&error)
managedObject = managedObjectContext.existingObjectWithID(managedObject.objectID, error: &error)!

managedObject.description