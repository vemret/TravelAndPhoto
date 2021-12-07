//
//  ViewController.swift
//  TravelAndPhoto
//
//  Created by Vahit Emre TELLİER on 7.12.2021.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var subtitleTF: UITextField!
    @IBOutlet weak var mapView: MKMapView!
//    CLLocationManager should be used if doing something related to location
    var locationManager = CLLocationManager()
    
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
//        Delegates should be used for using them classes or function
        mapView.delegate = self
        locationManager.delegate = self
//          desiredAccuracy should be used for accuracy in the map location
//        the bes lacation accuracy is kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        For user permission
        locationManager.requestWhenInUseAuthorization()
//        For take the user's location
        locationManager.startUpdatingLocation()
        
        
//        -------------------------RECOGNIZERS-----------------------------------
        
//        for pin
        let gestureRecognizer =  UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
//        for close keyboard
        let keyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(keyboardGestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]){
//        belki kullanıcı cancele basar belki ımage değildi oyuzde as? kullanıldı
        imageView.image = info[.originalImage] as? UIImage
//        Closing
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
//        editleme işleme bittikten sonra herhangi bir yere tıklanırsa birşey açıksa kapanacaktır
        view.endEditing(true)
    }
    
    @IBAction func SaveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlaces = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlaces.setValue(titleTF.text, forKey: "title")
        newPlaces.setValue(subtitleTF.text, forKey: "subtitle")
        newPlaces.setValue(choosenLatitude, forKey: "latitude")
        newPlaces.setValue(choosenLongitude, forKey: "longitude")
        newPlaces.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("Success")
        }catch{
            print("Error!")
        }
        
    }
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer){
//        Added gestureRecognizer to use defined functions
//        if gestureRecognizer is began, in other words user touch point in the map
        if gestureRecognizer.state == .began {
//            kullanıcıın dokunduğu locasyon alındı ve koordinata çevrildi sonra annatation oluşturulup mapview e eklendi
            let touchedLocation = gestureRecognizer.location(in: self.mapView)
//          touchedCoordinate give coordinate which toched by user
            let touchedCoordinate = mapView.convert(touchedLocation, toCoordinateFrom: self.mapView)
            
            choosenLatitude = touchedCoordinate.latitude
            choosenLongitude = touchedCoordinate.longitude
            
//            for add Pin preferences
            let annatation = MKPointAnnotation()
            annatation.coordinate = touchedCoordinate
            annatation.title = titleTF.text
            annatation.subtitle = subtitleTF.text
            mapView.addAnnotation(annatation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        didUpdateLocations locations: [CLLocation] is the updating location array
//        CLLocation enlem ve boylam objesi
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
//        for focus
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
    }

}

