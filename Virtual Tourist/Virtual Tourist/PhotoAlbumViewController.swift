//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by The Fasugba Crew  on 11/4/2023.
//

import UIKit
import MapKit
import AVFoundation
import Photos
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var NewCollection: UIButton!
    @IBOutlet weak var collectionPhotos: UICollectionView!
    @IBOutlet weak var Map: MKMapView!
    fileprivate let cellSize = UIScreen.main.bounds.width / 2
    var coordinate: CLLocationCoordinate2D!
    var dataController: DataController!
    var page: Int = 0
    let numberOfCellsPerRow: CGFloat = 4
    var pin: Pin!
    var photos: [Photo] = [] 
    var myString: String?
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionPhotos.delegate = self
        collectionPhotos.dataSource = self
        fetchPhotos()
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            Map.setRegion(region, animated: true)
        NewCollection.isEnabled = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
                fetchRequest.sortDescriptors = []
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController.delegate = self
                
                do {
                    try fetchedResultsController.performFetch()
                } catch {
                    fatalError("The fetch could not be performed: \(error.localizedDescription)")
                }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showPhoto" {
                let photoAlbumVC = segue.destination as! PhotoAlbumViewController
                let pin = sender as! Pin
                photoAlbumVC.pin = pin
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            let photo = photos[indexPath.row]
            if let imageUrl = URL(string: photo.url!) {
                // Download the image from the URL and display it in the cell
                URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.imageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let photo = fetchedResultsController.object(at: indexPath)
        let photo = photos[indexPath.row]
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
        photos.remove(at: indexPath.row)
        collectionPhotos.deleteItems(at: [indexPath])
    }
    
    let baseStaticFlickr = "https://live.staticflickr.com"
    func fetchPhotos() {
        let flickr = FlickrApiClient()
        FlickrApiClient.searchPhotos(latitude: coordinate.latitude, longitude: coordinate.longitude, page: Int.random(in: 1...10)) { [self] (photos, error) in
                    if let photos = photos {
                        for photo in photos.photos.photo{
                            let p = Photo(context: self.dataController.viewContext)
                            p.url = baseStaticFlickr + "/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
                            dataController.save()
                            self.photos.append(p)
                        }
                        DispatchQueue.main.async {
                            self.NewCollection.isEnabled = true
                            self.collectionPhotos.reloadData()
                        }
                    } else {
                        print(error?.localizedDescription ?? "Unknown error")
                    }
                }
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
            // Disable the "New Collection" button while photos are being downloaded
            NewCollection.isEnabled = false

        // Fetch all the photos associated with the current pin
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        let photos = try? dataController.viewContext.fetch(fetchRequest)

        // Delete all the fetched photos from Core Data
        photos?.forEach { dataController.viewContext.delete($0) }

        // Save the context to persist the changes
        try? dataController.viewContext.save()

        
            // Fetch new photos for the location
            fetchPhotos()
        
        }
    
    func deleteAllPhotos() {
        guard let pin = pin else {
            return
        }
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        if let photos = try? dataController.viewContext.fetch(fetchRequest) {
            for photo in photos {
                dataController.viewContext.delete(photo)
            }
            
            try? dataController.viewContext.save()
        }
    }
    
    }

