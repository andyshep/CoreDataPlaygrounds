var persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel:model)
persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error)
if error {
    println("error creating psc: \(error)")
}