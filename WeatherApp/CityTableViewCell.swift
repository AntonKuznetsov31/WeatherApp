import UIKit

class CityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCell(cell: CityTableViewCell, with weather: Weather) {
        guard let currently = weather.currently,
            let iconVal = currently.icon else { return }
        cell.icon.image = WeatherIconManager(rawValue: iconVal).image
        cell.temperature.text = currently.temperatureString
    }
}
