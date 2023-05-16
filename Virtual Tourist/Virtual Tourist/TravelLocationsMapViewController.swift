//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by The Fasugba Crew  on 8/4/2023.
//
import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var mapView: MKMapView!
    var dataController: DataController!
    var longPressGesture = UILongPressGestureRecognizer()
        var longPressActive = false
        var wasErrorDetected = false
    var selectedLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        
        
        // Set the map view's region to a default location and zoom level
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let regionRadius: CLLocationDistance = 1000
        let region = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
        
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Add a new MKAnnotation to the map view at the tapped location
        selectedLocation = view.annotation?.coordinate
        performSegue(withIdentifier: "showPhoto", sender: view)
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Customize the appearance of the added MKAnnotation
        let identifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
  
    func showAlertAction(title: String, message: String){
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                    print("Action")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    
    @objc func handleTap(_ sender: UIGestureRecognizer)
       {
           if sender.state == UIGestureRecognizer.State.ended {
               
               let touchPoint = sender.location(in: mapView)
               let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
               let annotation = MKPointAnnotation()
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
               dataController = appDelegate.dataController
               let pin = Pin(context: dataController.viewContext)
               pin.latitude = touchCoordinate.latitude
               pin.longitude = touchCoordinate.longitude
               try? dataController.viewContext.save()
               annotation.coordinate = touchCoordinate
               annotation.title = "New pin"
               mapView.addAnnotation(annotation)
               SingletonPin.sharedInstance().pins.append(pin)
               
               let photoVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
               let location = sender.location(in: mapView)
               let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
               photoVC.coordinate = coordinate
           }
           
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            let photoAlbumVC = segue.destination as! PhotoAlbumViewController
            photoAlbumVC.coordinate = (sender as! MKAnnotationView).annotation?.coordinate
        
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Pass the coordinate to the photo view controller
        let photoVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        photoVC.coordinate = coordinate
        performSegue(withIdentifier: "showPhoto", sender: photoVC)
    
        
    }

}

