managedObjectContext.save(&error)
if (error != nil) {
    println("error saving context: \(error)")
}