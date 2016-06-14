//: Playground - noun: a place where people can play

import UIKit
import CoreData
import PlaygroundSupport

let frame = CGRect(x: 0, y: 0, width: 320, height: 480)

class ViewController: UIViewController {
    
    let dataSource: DataSource
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Events"
        
        self.dataSource.tableView = self.tableView
        self.view.addSubview(self.tableView)
        
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(handleAddButton))
        self.navigationItem.rightBarButtonItem = item
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: frame)
        return tableView
    }()
    
    func handleAddButton(_ sender: AnyObject) {
        let context = self.dataSource.context
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Event", into: context)
        entity.setValue(Date(), forKey: "timestamp")
        
        try! context.save()
    }
}

let context = try createManagedObjectContext()
let dataSource = DataSource(context: context)

let viewController = ViewController(dataSource: dataSource)
let navController = UINavigationController(rootViewController: viewController)

navController.view.frame = frame

PlaygroundPage.current.liveView = navController.view
