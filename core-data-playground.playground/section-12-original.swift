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
