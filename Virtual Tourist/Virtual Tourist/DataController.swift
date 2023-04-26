//
//  DataController.swift
//  Virtual Tourist
//
//  Created by The Fasugba Crew  on 12/4/2023.
//

import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
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
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving data to Core Data: \(error.localizedDescription)")
        }
    }
    
    func deleteAllPhotos(for pin: Pin) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch {
            print("Error deleting photos from Core Data: \(error.localizedDescription)")
        }
    }
}
