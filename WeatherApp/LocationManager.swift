import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    private let locationManager = CLLocationManager()
    
    lazy var geocoder = CLGeocoder()
    
    override init() {
        super.init()
        self.locationManager.delegate = self as CLLocationManagerDelegate
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - Core Location Delegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    }
}

// MARK: - Get Location

extension LocationManager {
    
    func getLocationForAddress(address: String, completion: @escaping(CLLocation?) -> Void) {

        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in

            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }

            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }

            guard let location = placemark.location else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            completion(location)
        })
    }
    
    func getPlacemarkForLocation(location: CLLocation?, completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        
        if let myLocation = location {
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(myLocation, completionHandler: { placemarks, error in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                    
                }
                else {
                    // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
}
