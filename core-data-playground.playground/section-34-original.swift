var fetchRequest = NSFetchRequest(entityName: GROEntity.Neighborhood)
fetchRequest.predicate = NSPredicate(format: "population > %d", 15000)

var results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]
if (error != nil) {
    println("error executing fetch request: \(error)")
}

results.count

results[0].description
results[1].description