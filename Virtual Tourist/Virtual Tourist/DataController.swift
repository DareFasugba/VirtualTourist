//
//  DataController.swift
//  Virtual Tourist
//
//  Created by The Fasugba Crew  on 12/4/2023.
//

import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewsContext: NSManagedObjectContext{
            return persistentContainer.viewContext
        }
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
