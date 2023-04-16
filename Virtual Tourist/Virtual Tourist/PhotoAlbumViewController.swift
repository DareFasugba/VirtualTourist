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
    var selectedPin: CLLocationCoordinate2D?
    var dataController: DataController!
    var page: Int = 0
    let numberOfCellsPerRow: CGFloat = 4
    var pin: Pin!
    var photos: [Photo] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        cell.imageView.image = UIImage(data: photo.imageData!)
        return cell
    }
}
