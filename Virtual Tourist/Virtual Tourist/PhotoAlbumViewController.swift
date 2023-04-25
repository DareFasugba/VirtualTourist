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


class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionPhotos.delegate = self
        collectionPhotos.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
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
    func fetchPhotos() {
        let flickr = FlickrApiClient()
        FlickrApiClient.searchPhotos(latitude: coordinate.latitude, longitude: coordinate.longitude, page: 0) { (photos, error) in
                    if let photos = photos {
                        var downloadedPhotos = photos.photos
                        DispatchQueue.main.async {
                            self.collectionPhotos.reloadData()
                        }
                    } else {
                        print(error?.localizedDescription ?? "Unknown error")
                    }
                }
    }
    
    func getPhotosForLocation(_ pin: Pin) {
        // Construct the Flickr API URL for the specified location
        let url = FlickrAPI.url(for: pin.coordinate)
        
        // Create a URLSession task to download the photos from Flickr
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Error downloading photos: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Parse the JSON response from Flickr to get the photo URLs
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                  let photos = json["photos"] as? [String: Any],
                  let photoArray = photos["photo"] as? [[String: Any]] else {
                print("Error parsing JSON response")
                return
            }
            
            // Download each photo and save it to Core Data
            for photo in photoArray {
                guard let urlString = photo["url_m"] as? String,
                      let url = URL(string: urlString),
                      let imageData = try? Data(contentsOf: url) else {
                    print("Error downloading photo")
                    continue
                }
                
                // Save the photo to Core Data
                let newPhoto = Photo(context: self.dataController.viewContext)
                newPhoto.imageData = imageData
                newPhoto.pin = pin
                
                try? self.dataController.viewContext.save()
            }
        }
        
        // Start the URLSession task
        task.resume()
    }
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        guard let selectedPin = pin else {
            return
        }
        
        // Delete the existing photos associated with the pin
        dataController.viewContext.deleteAllPhotos(for: selectedPin)
        
        // Download a new set of photos from Flickr
        getPhotosForLocation(selectedPin)
        
        // Reload the collection view to display the new photos
        collectionView.reloadData()
    }
    }

