var neighborhoods = [[GROAttribute.Name:"Loyal Heights", GROAttribute.Population:10147],
                     [GROAttribute.Name:"Phinney Ridge", GROAttribute.Population:11732],
                     [GROAttribute.Name:"Greenwood", GROAttribute.Population:17111],
                     [GROAttribute.Name:"Wallingford", GROAttribute.Population:17451],
                     [GROAttribute.Name:"South Lake Union", GROAttribute.Population:4935],
                     [GROAttribute.Name:"Belltown", GROAttribute.Population:7399]]

for obj in neighborhoods {
    var neighborhood: AnyObject! = NSEntityDescription.insertNewObjectForEntityForName(GROEntity.Neighborhood, inManagedObjectContext: managedObjectContext)
    neighborhood.setValue(obj.valueForKey(GROAttribute.Name), forKey: GROAttribute.Name)
    neighborhood.setValue(obj.valueForKey(GROAttribute.Population), forKey: GROAttribute.Population)
    
    neighborhood.setValue(city, forKey: GRORelationship.City)
}
