##A Swift Introduction to Core Data

Let's create a basic Core Data model and populate it with two related entities. The two entities in our data model will be `City` and `Neighborhood`. There is one to many relationship between cities and neighborhoods. A `City` has many `Neighborhood`s, each `Neighborhood` belongs to one `City`. Here's a diagram representing the model.

    +---------------+              +----------------+
    | City          |              |  Neighborhood  |
    |---------------|              |----------------|
    | name          |              |  name          |
    | state         |              |  population    |
    | population    |              |                |
    |               |              |                |
    | neighborhoods | <--------->> |  city          |
    +---------------+              +----------------+

To get started, we'll import the module for CoreData.

```swift
import CoreData
```

Next we'll declare the some String constants up front. This is good practice and helps avoid typos, as we'll be referring to these often. By declaring them as constants, we can also leverage code completion.

```swift
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
```

We'll use an optional error variable for capturing any errors returned from Core Data.

```swift
var error: NSError? = nil
```

Next, define the [Managed Object Model](https://developer.apple.com/library/mac/documentation/DataManagement/Devpedia-CoreData/managedObjectModel.html). Typically this is done inside Xcode with the [Core Data Model Editor](https://developer.apple.com/library/mac/recipes/xcode_help-core_data_modeling_tool/Articles/about_cd_modeling_tool.html). Entities and Relationships are laid out graphically and a `.momd` file is generated at compile time. But we're inside a playground and don't have access to the model editor. No problem, the model can still be [declared in code](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdBasics.html#//apple_ref/doc/uid/TP40001650-207332-TPXREF151). This requires some boilerplate, but it's also a good learning exercise.

```swift
var model = NSManagedObjectModel()
```

Next create entity descriptions for the entities in the model. Our model will have two entities: `City` and `Neighborhood`

```swift
var cityEntity = NSEntityDescription()
cityEntity.name = GROEntity.City

var neighborhoodEntity = NSEntityDescription()
neighborhoodEntity.name = GROEntity.Neighborhood
```

[Entities](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdMOM.html#//apple_ref/doc/uid/TP40002328-SW5) have properties, in the form of attributes and relationships. In our model, a `City` has attributes for `name`, `state`, and `population` whereas a `Neighborhood` only has attributes for `name` and `population`. Attributes have a type. The `name` and `state` attribute are `.StringAttributeType` and the `population` is given a `Integer64AttributeType`. All the attributes are marked as required by setting `optional` to `false`. An attribute could also be marked as indexed...

```swift
var nameAttribute = NSAttributeDescription()
nameAttribute.name = GROAttribute.Name
nameAttribute.attributeType = NSAttributeType.StringAttributeType
nameAttribute.optional = false
nameAttribute.indexed = false

var stateAttribute = NSAttributeDescription()
stateAttribute.name = GROAttribute.State
stateAttribute.attributeType = NSAttributeType.StringAttributeType
stateAttribute.optional = false
stateAttribute.indexed = false

var populationAttribute = NSAttributeDescription()
populationAttribute.name = GROAttribute.Population
populationAttribute.attributeType = NSAttributeType.Integer64AttributeType
populationAttribute.optional = false
populationAttribute.indexed = false
```

Next declare the one-to-many relationship between `City` and `Neighborhoods`. The relationship needs to be declared on both ends, or between both entities. On one end of the relationship, the `neighborhoodEntity` is setup with a `maxCount` of zero. On the other end, the `cityEntity` is given a `maxCount` of one. This defines both ends of the one-to-many relationship. Connect the relationship fully using the `inverseRelationship` and point the relationships to each other.

```swift
var cityRelationship = NSRelationshipDescription()
var neighborhoodRelationship = NSRelationshipDescription()

neighborhoodRelationship.name = GRORelationship.Neighborhoods
neighborhoodRelationship.destinationEntity = neighborhoodEntity
neighborhoodRelationship.minCount = 0
neighborhoodRelationship.maxCount = 0
neighborhoodRelationship.deleteRule = NSDeleteRule.CascadeDeleteRule
neighborhoodRelationship.inverseRelationship = cityRelationship

cityRelationship.name = GRORelationship.City
cityRelationship.destinationEntity = cityEntity
cityRelationship.minCount = 0
cityRelationship.maxCount = 1
cityRelationship.deleteRule = NSDeleteRule.NullifyDeleteRule
cityRelationship.inverseRelationship = neighborhoodRelationship
```

The type and characteristics of the `name` and `population` attributes are identicial between `City` and `Neighborhood`-- the are both required strings. Given this, we can share the `NSAttributeDescription` between `City` and `Neighborhood` and create a copy so the attributes are unique.

```swift
cityEntity.properties = [nameAttribute, stateAttribute, populationAttribute, neighborhoodRelationship]
neighborhoodEntity.properties = [nameAttribute.copy(), populationAttribute.copy(), cityRelationship]
```

Setup the model with the entities we've created. At this point, the model for our use case is fully defined. We can now fit the model into the rest of the stack.

```swift
model.entities = [cityEntity, neighborhoodEntity]
```

Create a [Persistent Store Coordinator](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/persistentStoreCoordinator.html) (PSC) to communicate with the model we've declared. The coordinator is typically attached to an on disk SQL store with a URL. Because we're in a playground an [in memory store](https://developer.apple.com/library/mac/Documentation/Cocoa/Conceptual/CoreData/Articles/cdUsingPersistentStores.html) is used instead. When creating the PSC, you may include various options in the configuration dictionary, including specifying things like [migration policies](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/CoreDataVersioning/Articles/vmInitiating.html); we can ignore these options in our simplistic stack.

```swift
var persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel:model)
persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error)
if error {
    println("error creating psc: \(error)")
}
```

Create a [Managed Object Context](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/managedObjectContext.html) and attach the PSC to it. We'll use `.MainQueueConcurrencyType` in a single threaded environment.
```swift
var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
```

The stack is now setup and ready for use. Create a new `City` entity and insert it into the context. This is done by calling `insertNewObjectForEntityForName` on `NSEntityDescription` and including the name of the entity and the context that should create it. This will return an `NSManagedObject` instance for our entity. We can the set attribute values on the entity using key paths. A typical app, with a more complex data model, may [create subclasses of `NSManagedObject`](http://stackoverflow.com/questions/7947458/why-exactly-would-one-subclass-nsmanagedobject) for specific entities and set attributes using instance variables instead of keyPaths.

```swift
var city: AnyObject! = NSEntityDescription.insertNewObjectForEntityForName(GROEntity.City, inManagedObjectContext: managedObjectContext)

city.setValue("Seattle", forKeyPath: GROAttribute.Name)
city.setValue("Washington", forKeyPath: GROAttribute.State)
city.setValue(634535, forKeyPath: GROAttribute.Population)
```

A city is comprised of neighborhoods, so add those too. Create a dictionary containing key/value pairs corresponding to entity attributes. In a [real app](http://www.objc.io/issue-10/networked-core-data-application.html), this data might be retrieved as JSON from a web service.

```swift
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
```

Until this point, the context has remained 'empty'. When the context is saved it will send out notificatons about the object state changes. As an optional state, we can create an `NotificationListener` and subscribe to the context notifications. In a real app, this object would likely correspond to a fetched results controller or another object on your data model. On iOS, a [Fetched Results Controller](https://developer.apple.com/library/ios/documentation/CoreData/Reference/NSFetchedResultsController_Class/Reference/Reference.html) provides a nice abstraction for responding to change notifications. Below, we'll use [`printf()` debugging](http://stackoverflow.com/a/189570) to peak behind the scenes and examine the notifications sent by Core Data.

```swift
class NotificationListener: NSObject {
    func handleDidChangeNotification(notification:NSNotification) {
        println("did change notification received: \(notification)")
    }
    func handleDidSaveNotification(notification:NSNotification) {
        println("did save notification received: \(notification)")
    }
}

let delegate = NotificationListener()
NSNotificationCenter.defaultCenter().addObserver(delegate, selector: "handleDidChangeNotification:", name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
NSNotificationCenter.defaultCenter().addObserver(delegate, selector: "handleDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil)
```

Save the context so it's populated with the entities.

```swift
managedObjectContext.save(&error)
if error {
    println("error saving context: \(error)")
}
```

After the context saved, we can query it by creating a [Fetch Request](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/fetchRequest.html). We'll use a predicate to only return `Neighborhood` entities with a `population` greater than 15000. In our data model, two such entities exist.

```swift
var fetchRequest = NSFetchRequest(entityName: GROEntity.Neighborhood)
fetchRequest.predicate = NSPredicate(format: "population > %d", 15000)

var results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
if error {
    println("error executing fetch request: \(error)")
}

results.count

results[0].description
results[1].description
```