var city: AnyObject! = NSEntityDescription.insertNewObjectForEntityForName(GROEntity.City, inManagedObjectContext: managedObjectContext)

city.setValue("Seattle", forKeyPath: GROAttribute.Name)
city.setValue("Washington", forKeyPath: GROAttribute.State)
city.setValue(634535, forKeyPath: GROAttribute.Population)
