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
