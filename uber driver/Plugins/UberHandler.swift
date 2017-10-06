//
//  UberProvider.swift
//  uber driver
//
//  Created by kidnapper on 24/09/2017.
//  Copyright © 2017 kidnapper.com. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class {
    func acceptUber(lat: Double, long: Double)
    func riderCanceledUber()
    func uberCanceled()
    func updateRidersLocation(lat: Double, long: Double)
}

class UberHandler{
    private static let _instance = UberHandler()
    
    weak var delegate: UberController?
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    static var Instance: UberHandler{
        return _instance
    }
    
    func observeMessageForDriver() {
        
        //Rider request an uber
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGTITUDE] as? Double{
                        self.delegate?.acceptUber(lat: latitude, long: longitude)
                    }
                }
                if let name = data[Constants.NAME]{
                    self.rider = name as! String
                }
            }
        }
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.rider = ""
                        self.delegate?.riderCanceledUber()
                    }
                }
            }
        }
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        self.driver_id = snapshot.key
                    }
                }
            }
        }
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        self.delegate?.uberCanceled()
                    }
                }
            }
        }
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let lat = data[Constants.LATITUDE] as? Double{
                    if let long = data[Constants.LONGTITUDE] as? Double {
                        self.delegate?.updateRidersLocation(lat: lat, long: long)
                        print("run here")
                    }
                }
            }
        }
    }
    func uberAccepted(lat: Double, long: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: self.driver, Constants.LATITUDE: lat, Constants.LONGTITUDE: long]
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
        
    }
    func cancelUberForDriver(){
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue()
    }
    //self canceled after accepted request
    func uberCanceled(){
        
    }
    func updateDriverLocation(lat: Double, long: Double){
        DBProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGTITUDE: long])
    }
}













