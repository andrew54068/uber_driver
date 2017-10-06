//
//  DriverVC.swift
//  uber driver
//
//  Created by kidnapper on 24/09/2017.
//  Copyright © 2017 kidnapper.com. All rights reserved.
//

import UIKit
import MapKit

class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {

    
    @IBOutlet var acceptUber: UIButton!
    @IBOutlet var myMap: MKMapView!
    
    private var acceptedUber = false
    private var driverCanceledUber = false
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.delegate = self
        UberHandler.Instance.observeMessageForDriver()
        
        
        // Do any additional setup after loading the view.
    }
    
    private func initializeLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            myMap.setRegion(region, animated: true)
            print("riderLocation is \(String(describing: riderLocation))")
            
            myMap.removeAnnotations(myMap.annotations)
            if riderLocation != nil{
                if acceptedUber{
                    let riderAnnotation = MKPointAnnotation()
                    riderAnnotation.coordinate = riderLocation!
                    riderAnnotation.title = "Riders Location"
//                    riderAnnotation.superclass?.greenPinColor()
                    myMap.addAnnotation(riderAnnotation)
                    print("show annotaion")
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = "Driver Location"
            annotation.coordinate = userLocation!
            myMap.addAnnotation(annotation)
        }
    }
    @objc func updateDriversLocation() {
        UberHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    func updateRidersLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func acceptUber(lat: Double, long: Double) {
        if !acceptedUber{
            uberRequest(title: "Uber Request", message: "You have a uber request in this location: \(lat), \(long)", requestAlive: true)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logout(){
            
            if acceptedUber {
                UberHandler.Instance.cancelUberForDriver()
                
                timer.invalidate()
            }
            
            dismiss(animated: true, completion: nil)
            
            
        }else{
            self.uberRequest(title: "Could Not Logout", message: "Please Try Again Later", requestAlive: false)
        }
    }
    func riderCanceledUber() {
        if acceptedUber{
            if !driverCanceledUber{
                self.acceptedUber = false
                self.acceptUber.isHidden = true
                uberRequest(title: "Uber Canceled", message: "The Rider  Has Canceled The Uber", requestAlive: false)
                UberHandler.Instance.cancelUberForDriver()
                timer.invalidate()
            }else{
                self.acceptedUber = false
                self.acceptUber.isHidden = true
                timer.invalidate()
            }
        }
    }
    func uberCanceled() {
        if acceptedUber {
            acceptedUber = false
            acceptUber.isHidden = true
//            UberHandler.Instance.cancelUberForDriver()
            
        }
    }
    
    @IBAction func cancelUber(_ sender: Any) {
        if acceptedUber {
            UberHandler.Instance.cancelUberForDriver()
            driverCanceledUber = true
            acceptUber.isHidden = true
            timer.invalidate()
        }
    }
    
    private func uberRequest(title: String, message: String, requestAlive: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if requestAlive{
            let accept = UIAlertAction(title: "accept", style: .default, handler: {(alertAction: UIAlertAction) in
                self.acceptedUber = true
                self.acceptUber.isHidden = false
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(DriverVC.updateDriversLocation), userInfo: nil, repeats: true)
                UberHandler.Instance.uberAccepted(lat: Double(self.userLocation!.latitude), long: self.userLocation!.longitude)
                
            })
            let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)
            alert.addAction(accept)
            alert.addAction(cancel)
        }else{
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
        }
        present(alert, animated: true, completion: nil)
    }
    

}
