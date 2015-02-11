var persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel:model)
persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error)
if (error != nil) {
    println("error creating psc: \(error)")
}
