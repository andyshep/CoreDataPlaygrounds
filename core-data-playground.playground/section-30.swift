class NotificationListener: NSObject {
    func handleDidSaveNotification(notification:NSNotification) {
        println("did save notification received: \(notification)")
    }
}

let delegate = NotificationListener()
NSNotificationCenter.defaultCenter().addObserver(delegate, selector: "handleDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil)
