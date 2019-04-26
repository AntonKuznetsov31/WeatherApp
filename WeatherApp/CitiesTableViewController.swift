import UIKit
import CoreData

class CitiesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchResultsController: NSFetchedResultsController<City>!
    var searchController: UISearchController!
    var cities: [City] = []
    
    private let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
            
            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController.delegate = self as NSFetchedResultsControllerDelegate
            
            do {
                try fetchResultsController.performFetch()
                cities = fetchResultsController.fetchedObjects!
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func unwindToCities(segue:UIStoryboardSegue) {
        if segue.identifier == "unwindToCities" {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailWeather" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let dvc = segue.destination as! CityWeatherViewController
                dvc.city = cityToDisplayAt(indexPath: indexPath)
            }
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func cityToDisplayAt(indexPath: IndexPath) -> City {
        let city: City
        city = cities[indexPath.row]
        return city
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CityTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityTableViewCell
        let city = cityToDisplayAt(indexPath: indexPath)
        
        NetworkManager.fetchWeatherForCity(city: city) { (weather) in
            DispatchQueue.main.async {
                cell.updateCell(cell: cell, with: weather)
            }
        }
        
        cell.cityName.text = city.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
            self.cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
                
                let objectToDelete = self.fetchResultsController.object(at: indexPath)
                context.delete(objectToDelete)
                
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Fetch Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert: guard let indexPath = newIndexPath else { break }
        tableView.insertRows(at: [indexPath], with: .fade)
        case .delete: guard let indexPath = newIndexPath else { break }
        tableView.deleteRows(at: [indexPath], with: .fade)
        case .update: guard let indexPath = newIndexPath else { break }
        tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            tableView.reloadData()
        }
        cities = controller.fetchedObjects as! [City]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
