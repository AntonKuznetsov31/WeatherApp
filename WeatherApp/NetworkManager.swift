import Foundation

class NetworkManager {
    
    static func fetchWeatherForCity(city: City, completion: @escaping ((Weather) -> Void)) {
        let urlString = "https://api.darksky.net/forecast/51fca834283ad4e4ec46feeef0588c7a/\(city.latitude),\(city.longitude)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else { return }
            guard error == nil else { return }
            
            do {
                let json = try JSONDecoder().decode(Weather.self, from: data)
                completion(json)
            } catch DecodingError.dataCorrupted(let context) {
                print(context)
            } catch DecodingError.keyNotFound(let key, let context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch DecodingError.valueNotFound(let value, let context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch DecodingError.typeMismatch(let type, let context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }.resume()
    }
}
