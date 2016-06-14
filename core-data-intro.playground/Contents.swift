//: ## A Swift Introduction to Core Data
//:
//: Let's create a basic Core Data model and populate it with two related entities. The two entities in our data model will be City and Neighborhood. There is a one-to-many relationship between cities and neighborhoods. A City has many Neighborhoods and each Neighborhood belongs to one City. Here's a diagram representing the model.
//:
//:     +---------------+              +----------------+
//:     | City          |              |  Neighborhood  |
//:     |---------------|              |----------------|
//:     | name          |              |  name          |
//:     | state         |              |  population    |
//:     | population    |              |                |
//:     |               |              |                |
//:     | neighborhoods | <--------->> |  city          |
//:     +---------------+              +----------------+
//:
//: To get started, we'll import the module for CoreData.

import CoreData

//: Next we'll declare the some String constants up front. This is good practice and helps avoid typos, as we'll be referring to these often. By declaring them as constants, we can also leverage code completion.

struct GROEntity {
    static let City = "City"
    static let Neighborhood = "Neighborhood"
}

struct GROAttribute {
    static let Name = "name"
    static let State = "state"
    static let Population = "population"
}

struct GRORelationship {
    static let Neighborhoods = "neighborhoods"
    static let City = "city"
}

//: Next define the [Managed Object Model](https://developer.apple.com/library/mac/documentation/DataManagement/Devpedia-CoreData/managedObjectModel.html). Typically this is done inside Xcode with the [Core Data Model Editor](https://developer.apple.com/library/mac/recipes/xcode_help-core_data_modeling_tool/Articles/about_cd_modeling_tool.html). Entities and Relationships are laid out graphically and a `.momd` file is generated at compile time. But we're inside a playground and don't have access to the model editor. No problem, the model can still be [declared in code](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdBasics.html#//apple_ref/doc/uid/TP40001650-207332-TPXREF151). This requires some boilerplate, but it's also a good learning exercise.

let model = NSManagedObjectModel()

//: Next create entity descriptions for the entities in the model. Our model will have two entities: `City` and `Neighborhood`

let cityEntity = NSEntityDescription()
cityEntity.name = GROEntity.City

let neighborhoodEntity = NSEntityDescription()
neighborhoodEntity.name = GROEntity.Neighborhood

//: [Entities](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdMOM.html#//apple_ref/doc/uid/TP40002328-SW5) have properties, in the form of attributes and relationships. In our model, a `City` has attributes for `name`, `state`, and `population` whereas a `Neighborhood` only has attributes for `name` and `population`. Attributes have a type. The `name` and `state` attribute are `.StringAttributeType` and the `population` is given a `Integer64AttributeType`. All the attributes are marked as required by setting `optional` to `false`. An attribute could also be marked as indexed...

let nameAttribute = NSAttributeDescription()
nameAttribute.name = GROAttribute.Name
nameAttribute.attributeType = NSAttributeType.stringAttributeType
nameAttribute.isOptional = false
nameAttribute.isIndexed = false

let stateAttribute = NSAttributeDescription()
stateAttribute.name = GROAttribute.State
stateAttribute.attributeType = NSAttributeType.stringAttributeType
stateAttribute.isOptional = false
stateAttribute.isIndexed = false

let populationAttribute = NSAttributeDescription()
populationAttribute.name = GROAttribute.Population
populationAttribute.attributeType = NSAttributeType.integer64AttributeType
populationAttribute.isOptional = false
populationAttribute.isIndexed = false

//: Next declare the one-to-many relationship between `City` and `Neighborhoods`. The relationship needs to be declared on both ends, or between both entities. On one end of the relationship, the `neighborhoodEntity` is setup with a `maxCount` of zero. On the other end, the `cityEntity` is given a `maxCount` of one. This defines both ends of the relationship. To connect the relationship fully, set the `inverseRelationship` property on each relationship to point to the other.

let cityRelationship = NSRelationshipDescription()
let neighborhoodRelationship = NSRelationshipDescription()

neighborhoodRelationship.name = GRORelationship.Neighborhoods
neighborhoodRelationship.destinationEntity = neighborhoodEntity
neighborhoodRelationship.minCount = 0
neighborhoodRelationship.maxCount = 0
neighborhoodRelationship.deleteRule = NSDeleteRule.cascadeDeleteRule
neighborhoodRelationship.inverseRelationship = cityRelationship

cityRelationship.name = GRORelationship.City
cityRelationship.destinationEntity = cityEntity
cityRelationship.minCount = 0
cityRelationship.maxCount = 1
cityRelationship.deleteRule = NSDeleteRule.nullifyDeleteRule
cityRelationship.inverseRelationship = neighborhoodRelationship

//: The type and characteristics of the `name` and `population` attributes are identical between `City` and `Neighborhood`-- the are both required strings. Given this, we can share the `NSAttributeDescription` between `City` and `Neighborhood` and create a copy so the attributes are unique.

cityEntity.properties = [nameAttribute, stateAttribute, populationAttribute, neighborhoodRelationship]
neighborhoodEntity.properties = [nameAttribute, populationAttribute, cityRelationship].map { return ($0.copy() as! NSPropertyDescription) }
//: Setup the model with the entities we've created. At this point the model for our use case is fully defined. We can now fit the model into the rest of the stack.

model.entities = [cityEntity, neighborhoodEntity]

//: Create a [Persistent Store Coordinator](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/persistentStoreCoordinator.html) (PSC) to communicate with the model we've declared. The coordinator is typically attached to an on disk SQL store with a URL. Because we're in a playground an [in memory store](https://developer.apple.com/library/mac/Documentation/Cocoa/Conceptual/CoreData/Articles/cdUsingPersistentStores.html) is used instead. When creating the PSC, you may include various options in the configuration dictionary, including specifying things like [migration policies](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/CoreDataVersioning/Articles/vmInitiating.html); we can ignore these options in our simplistic stack.

let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel:model)

do {
    try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
}
catch {
    print("error creating psc: \(error)")
}

//: Create a [Managed Object Context](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/managedObjectContext.html) and attach the PSC to it. We'll use `.MainQueueConcurrencyType` in a single threaded environment.

let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

//: The stack is now setup and ready to use. Create a new `City` entity and insert it into the context. This is done by calling `insertNewObjectForEntityForName` on `NSEntityDescription` and including the name of the entity and the context that should create it. This will return an `NSManagedObject` instance for our entity. We can then set attribute values on the entity using key paths. A typical app, with a more complex data model, may [create subclasses of `NSManagedObject`](http://stackoverflow.com/questions/7947458/why-exactly-would-one-subclass-nsmanagedobject) for specific entities and set attributes using instance variables instead of key paths.

let city = NSEntityDescription.insertNewObject(forEntityName: GROEntity.City, into: managedObjectContext)

city.setValue("Seattle", forKeyPath: GROAttribute.Name)
city.setValue("Washington", forKeyPath: GROAttribute.State)
city.setValue(634535, forKeyPath: GROAttribute.Population)

//: In addition to the `insertNewObjectForEntityForName` convienence method, an entity can also be created by initializing an `NSManagedObject` with an `NSEntityDescription`.

let entity = NSEntityDescription.entity(forEntityName: GROEntity.City, in: managedObjectContext)
let city2 = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
city2.setValue("San Francisco", forKeyPath: GROAttribute.Name)
city2.setValue("California", forKeyPath: GROAttribute.State)
city2.setValue(825863, forKeyPath: GROAttribute.Population)

//: A city has neighborhoods, so let's add those too. Create a dictionary containing key/value pairs corresponding to entity attributes. A [real app](http://www.objc.io/issue-10/networked-core-data-application.html) might retreive this data as JSON from a web service.

let neighborhoods = [[GROAttribute.Name:"Loyal Heights", GROAttribute.Population:10147],
    [GROAttribute.Name:"Phinney Ridge", GROAttribute.Population:11732],
    [GROAttribute.Name:"Greenwood", GROAttribute.Population:17111],
    [GROAttribute.Name:"Wallingford", GROAttribute.Population:17451],
    [GROAttribute.Name:"South Lake Union", GROAttribute.Population:4935],
    [GROAttribute.Name:"Belltown", GROAttribute.Population:7399]]

for obj in neighborhoods {
    var neighborhood = NSEntityDescription.insertNewObject(forEntityName: GROEntity.Neighborhood, into: managedObjectContext)
    neighborhood.setValue(obj[GROAttribute.Name], forKey: GROAttribute.Name)
    neighborhood.setValue(obj[GROAttribute.Population], forKey: GROAttribute.Population)
    
    neighborhood.setValue(city, forKey: GRORelationship.City)
}

//: Until this point, the context has remained "empty", per se. When the context is saved it will send out notifications about the object state changes. As an optional step, we can create a `NotificationListener` and subscribe to the context notifications. In an iOS app, this object would likely correspond to a [Fetched Results Controller](https://developer.apple.com/library/ios/documentation/CoreData/Reference/NSFetchedResultsController_Class/Reference/Reference.html) or another object on your data model. In a Playground setup, we'll use [`printf()` debugging](http://stackoverflow.com/a/189570) to peak behind the scenes and examine the notifications sent by Core Data.`

class NotificationListener: NSObject {
    func handleDidSaveNotification(_ notification:Notification) {
        print("did save notification received: \(notification)")
    }
}

let delegate = NotificationListener()
NotificationCenter.default().addObserver(delegate, selector: #selector(NotificationListener.handleDidSaveNotification(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)

//: Save the context so it's populated with the entities.
do {
    try managedObjectContext.save()
}
catch {
    print("error saving context: \(error)")
}

//: After the context saved, we can query it by creating a [Fetch Request](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/fetchRequest.html). We'll use a [predicate](https://developer.apple.com/library/mac/documentation/cocoa/reference/Foundation/Classes/NSPredicate_Class/Reference/NSPredicate.html) to return `Neighborhood` entities with a `population` greater than 15000. Only two such entities exist in the data model.

var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: GROEntity.Neighborhood)
fetchRequest.predicate = Predicate(format: "population > %d", 15000)

var results: [NSManagedObject] = []

do {
    results = try managedObjectContext.fetch(fetchRequest)
}
catch {
    print("error executing fetch request: \(error)")
}


assert(results.count >= 2, "wrong number of results")

results[0].value(forKey: GROAttribute.Name)
results[1].value(forKey: GROAttribute.Name)

//: Every managed object is assigned managed object id from the context. An [`NSManagedObjectID`](https://developer.apple.com/library/mac/documentation/cocoa/reference/CoreDataFramework/Classes/NSManagedObjectID_Class/Reference/NSManagedObjectID.html) is a unique id that can be used to reference managed objects across contexts. Consider the example below where `secondObject` is returned from another context by referencing a managed object id.

var firstObject: NSManagedObject?
var secondObject: NSManagedObject?

guard let moid = results.first?.objectID else { fatalError("no object id was found") }
let secondContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
secondContext.persistentStoreCoordinator = persistentStoreCoordinator

do {
    firstObject = try managedObjectContext.existingObject(with: moid)
    secondObject = try secondContext.existingObject(with: moid)
}
catch {
    print("error finding objects: \(error)")
}
    
firstObject?.value(forKey: GROAttribute.Name)
secondObject?.value(forKey: GROAttribute.Name)
    
//: Attributes and relationships on a managed object may be changed. When the context is saved the changes made to the managed objects are persisted. In the example below the `population` attribute of a `Neighborhood` entity is changed and the context to saved.
    
fetchRequest = NSFetchRequest(entityName: GROEntity.Neighborhood)
fetchRequest.predicate = Predicate(format: "name = %@", "Belltown")

do {
    results = try managedObjectContext.fetch(fetchRequest)
}
catch {
    print("error executing fetch: \(error)")
}

var managedObject = results.first

managedObject?.value(forKey: GROAttribute.Name)
managedObject?.setValue(1000, forKey: GROAttribute.Population)

do {
    let objectId = (managedObject?.objectID)!
    try managedObjectContext.save()
    managedObject = try managedObjectContext.existingObject(with: objectId)
}
catch {
    print("error finding object: \(error)")
}

managedObject?.value(forKey: GROAttribute.Name)

if let managedObject = managedObject {
    
//: Objects can be deleted through the context. Once deleted, they can no longer be retrieved by object id.
    do {
        managedObjectContext.delete(managedObject)
        try managedObjectContext.save()
    }
    catch {
        print("error deleting object: \(error)")
    }
    
//: This should fail, object with id not found. The object has been deleted.
    do {
        let managedObject = try managedObjectContext.existingObject(with: managedObject.objectID)
    }
    catch {
        print("error executing fetch request: \(error)")
    }
}

//: That wraps up a basic introduction to Core Data using a Swift and a Playground. The Core Data framework is big and there's [much more explore](http://www.objc.io/issue-4/). For more information, consider reading through the [Core Data Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdBasics.html) or looking at the source for a Core Data [template project in Xcode](http://code.tutsplus.com/tutorials/core-data-from-scratch-core-data-stack--cms-20926).
