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

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var subtitleTF: UITextField!
    @IBOutlet weak var mapView: MKMapView!
//    CLLocationManager should be used if doing something related to location
    var locationManager = CLLocationManager()
    
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    
    var selectedID : UUID?
    var selectedTitle = ""
    
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLongitude = Double()
    var annotationLatitude = Double()
    var annotationIMG = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        savebutton eneable
        saveButton.isEnabled = false

        
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
        

        
        if selectedTitle != "" {
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let stringID = selectedID!.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", stringID)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                if let longitude = result.value(forKey: "longitude") as? Double {
                                    annotationLongitude = longitude
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                        if let imgData = result.value(forKey: "image") as? Data {
                                            let img = UIImage(data: imgData)
                                            annotationIMG = img!
                                            
                            //                  for add Pin preferences
                                            let annatation = MKPointAnnotation()
                                            annatation.title = annotationTitle
                                            annatation.subtitle = annotationSubtitle
                                            
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        
                                            annatation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annatation)
                                            
                                            titleTF.text = annotationTitle
                                            subtitleTF.text = annotationSubtitle
                                            imageView.image = annotationIMG
                                            
//                                            Haritanın kayıtlı pin'in olduğu noktaya gitmesi için
                                            locationManager.stopUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }catch{
                print("Error!")
            }
            
        } else {

        }
        
    }
    
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (UIAlertAction) in
            print("Ok")
            }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
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
//        savebutton eneable
        saveButton.isEnabled = true
//        Closing
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
//        editleme işleme bittikten sonra herhangi bir yere tıklanırsa birşey açıksa kapanacaktır
        view.endEditing(true)
    }
    
    @IBAction func SaveButtonClicked(_ sender: Any) {
        if titleTF.text != "" && subtitleTF.text != "" && choosenLatitude != 0.0 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newPlaces = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
            
            newPlaces.setValue(titleTF.text, forKey: "title")
            newPlaces.setValue(subtitleTF.text, forKey: "subtitle")
            newPlaces.setValue(choosenLatitude, forKey: "latitude")
            newPlaces.setValue(choosenLongitude, forKey: "longitude")
            newPlaces.setValue(UUID(), forKey: "id")
            let data = imageView.image?.jpegData(compressionQuality: 0.5)
            newPlaces.setValue(data, forKey: "image")
            
            do{
                try context.save()
                print("Success")
            }catch{
                print("Error!")
            }
        } else {
            makeAlert(titleInput: "Empty Field-s!", messageInput: "Title or Comment or Location or Image is/are empty! Please fillin the empty field.")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer){
        
//        Added gestureRecognizer to use defined functions
//        if gestureRecognizer is began, in other words user touch point in the map
        if gestureRecognizer.state == .began {
            if titleTF.text != "" && subtitleTF.text != "" {
//               kullanıcıın dokunduğu locasyon alındı ve koordinata çevrildi sonra annatation oluşturulup mapview e eklendi
                let touchedLocation = gestureRecognizer.location(in: self.mapView)
//                  touchedCoordinate give coordinate which toched by user
                let touchedCoordinate = mapView.convert(touchedLocation, toCoordinateFrom: self.mapView)
                
                choosenLatitude = touchedCoordinate.latitude
                choosenLongitude = touchedCoordinate.longitude
            
//                  for add Pin preferences
                let annatation = MKPointAnnotation()
                annatation.coordinate = touchedCoordinate
                annatation.title = titleTF.text
                annatation.subtitle = subtitleTF.text
                mapView.addAnnotation(annatation)
            } else{
                makeAlert(titleInput: "Title or/and Comment are empty!", messageInput: "Please fillin the empty text field.")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        selectedTitle == "" nedeni kayıtlı lokasyona gidildiğinde çalışmaması için kayıtlı lokasyon yoksa yani çekilmiş veri yoksa çalışıyor.
        if selectedTitle == "" {
    //        didUpdateLocations locations: [CLLocation] is the updating location array
    //        CLLocation enlem ve boylam objesi
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
    //        for focus
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
        } else {
//            empty
        }
    }
    
//    pine tıklayımca ! ifadesi çıkması ve bu ifade sayesinede navigasyona bağlanması için
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        kullanıcın yerini pin ile gösteriliyorsa null yap gösterme, sadece tıklanılan yerin gösterilmesi gerekiyor
        if annotation is MKUserLocation {
            return nil
        }
//        Id nin ne olduğu hiç farketmez
        let reuseID = "myAnnotation"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
//        if pineview cannot be created
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
//            balancukta bilgi gösterilen yer
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.blue
            
//            detay gösterilen bir button oluşturuldu.
            let button  = UIButton(type: UIButton.ButtonType.detailDisclosure)
//            sohow the button on right side
            pinView?.rightCalloutAccessoryView = button
        } else {
//            if pinview can be created before, add the given anatation
//            pinview daha  önce  oluşturulduysa, verilen anatation ekler
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
//    balondaki butona basıldığını anlayan fonksiyon
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
//            placemark reverseGeocodeLocation ile alınıyor
            CLGeocoder().reverseGeocodeLocation(requestLocation){ (placemarks, error) in
//                closure
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        
//                        mapItemı oluşturabilmek için placemar objesi gerekiyor
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
//                        navigasyonun içinde Mapi açmak için MapItem gerekiyor
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
//                        selected Map mode such as with car
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
                
            }
        }
    }

}

