import UIKit
import Foundation
import MapKit
import CoreData

class NewCityViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let sC = MKLocalSearchCompleter()
        sC.delegate = self
        sC.filterType = .locationsOnly
        return sC
    }()
    
    var searchSource: [String]?     // user's search results
    
    private let locationManager = LocationManager()
    
    func saveCityByPlacemark(placemark: CLPlacemark, inContext context: NSManagedObjectContext) {
        let newCity = City(context: context)
        
        guard let myCountryName = placemark.country else { return }
        guard let myCityName = placemark.locality else { return }
        
        newCity.country = myCountryName
        newCity.name = myCityName
        
        self.locationManager.getLocationForAddress(address: "\(myCountryName), \(myCityName)") { location in
            
            guard let myCityLongitude = location?.coordinate.longitude else { return }
            guard let myCityLatitude = location?.coordinate.latitude else { return }
            
            newCity.longitude = myCityLongitude
            newCity.latitude = myCityLatitude
            
            do {
                try context.save()
                
            } catch let error as NSError {
                print("Error \(error), \(error.userInfo)")
            }
        }
    }
    
    func isCityInList(cityName: String, inContext context: NSManagedObjectContext) -> Bool {
        let myRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
        
        myRequest.predicate = NSPredicate(format: "name = %@", cityName)
        
        do {
            let results = try context.fetch(myRequest)
            
            if results.isEmpty == false {
                return true
            }
        } catch let error{
            print(error)
        }
        
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension NewCityViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
        } else {
            searchSource?.removeAll()
        }
        
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
        }
    }
}

// MARK: - Table View Data Source

extension NewCityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.searchTableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! SearchLocationCell
        
        cell.locationLabel.text = self.searchSource?[indexPath.row]
        
        return cell
    }
}

// MARK: - Table View Delegate

extension NewCityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext else { return }
        
        guard let address = self.searchSource?[indexPath.row]  else { return }
        
        self.locationManager.getLocationForAddress(address: address) { location in
            guard let mylocation = location else { return }
            
            self.locationManager.getPlacemarkForLocation(location: mylocation) { placemark in
                guard let myPlacemark = placemark else { return }
                
                // check if user's city unavailable
                if myPlacemark.country == nil || myPlacemark.locality == nil {
                    
                    let wrongCityAlert = UIAlertController()
                    wrongCityAlert.showAlertControllerOnView(view: self, withTitle: "Please choose another city", andMessage: "We can't find this city on map")
                    
                    return
                    
                    // check if user's city already in our database
                } else if self.isCityInList(cityName: myPlacemark.locality!, inContext: context) {
                    
                    let duplicateAlert = UIAlertController()
                    duplicateAlert.showAlertControllerOnView(view: self, withTitle: "Please choose new city", andMessage: "City you have chosen is already in list")
                    
                    return
                    
                }
                
                self.saveCityByPlacemark(placemark: myPlacemark, inContext: context)
                
            }
        }
    }
}

extension NewCityViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let digitsCharacterSet = NSCharacterSet.decimalDigits // set is using to filter search results
        // if results doesn't contain "," or contains digit - it's not a city
        let filteredResults = completer.results.filter { result in
            
            if !result.title.contains(",") {
                return false
            }
            
            if result.title.rangeOfCharacter(from: digitsCharacterSet) != nil {
                return false
            }
            
            if result.subtitle.rangeOfCharacter(from: digitsCharacterSet) != nil {
                return false
            }
            
            return true
        }
        
        self.searchSource = filteredResults.map { $0.title }
        
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension UIAlertController {
    
    func showAlertControllerOnView(view: UIViewController, withTitle title: String, andMessage message: String) {
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        view.present(alertController, animated: true)
    }
}
