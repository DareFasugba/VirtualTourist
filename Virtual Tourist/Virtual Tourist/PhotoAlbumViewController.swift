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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoAlbum" {
            guard let annotationView = sender as? MKAnnotationView,
                  let annotation = annotationView.annotation as? Pin else {
                return
            }
            
            let photoAlbumVC = segue.destination as! PhotoAlbumViewController
            photoAlbumVC.pin = annotation
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
    }

