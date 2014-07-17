managedObjectContext.deleteObject(managedObject)
managedObjectContext.save(&error)

managedObject = managedObjectContext.existingObjectWithID(managedObject!.objectID, error: &error)