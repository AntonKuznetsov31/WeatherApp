import UIKit

class CityWeatherViewController: UIViewController {
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var sunRise: UILabel!
    @IBOutlet weak var sunSet: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var humidity: UILabel!
    var city: City?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let city = self.city {
            DispatchQueue.main.async {
                self.updateUIWithWeatherForCity(city: city)
            }
        }
    }
    
    func updateUIWithWeatherForCity(city: City) {
        NetworkManager.fetchWeatherForCity(city: city, completion: { (weather) in
            
            guard let currently = weather.currently else { return }
            
            guard let iconVal = currently.icon,
                let temperatureVal = currently.temperatureString,
                let humidityVal = currently.humidityString,
                let windSpeedVal = currently.windSpeedString,
                let pressureVal = currently.pressureString else { return }
            
            DispatchQueue.main.async {
                self.icon.image = WeatherIconManager(rawValue: iconVal).image
                self.temperature.text = temperatureVal
                self.humidity.text = humidityVal
                self.windSpeed.text = windSpeedVal
                self.pressure.text = pressureVal
                
                guard let daily = weather.daily,
                    let data = daily.data,
                    let currentData = data.first else { return }
                self.sunRise.text = currentData.sunRiseString
                self.sunSet.text = currentData.sunSetString
                self.location.text = "\(city.name!), \(city.country!)"
            }
        })
    }
}
