managedObjectContext.save(&error)
if error {
    println("error saving context: \(error)")
}