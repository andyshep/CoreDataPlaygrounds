managedObjectContext.deleteObject(managedObject)
managedObjectContext.save(&error)

// should fail, object with id not found
if let managedObject = managedObjectContext.existingObjectWithID(managedObject.objectID, error: &error) {
    
} else {
    error!.description
}