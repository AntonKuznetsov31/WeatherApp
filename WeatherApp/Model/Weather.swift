import Foundation

struct Weather: Decodable {
    let latitude: Double?
    let longitude: Double?
    let timezone: String?
    let currently: Currently?
    let hourly: Hourly?
    let daily: Daily?
    let flags: Flags?
    let offset: Int?
}

struct Currently: Decodable {
    let time: Int?
    let summary: String?
    let icon: String?
    let temperature: Double?
    let humidity: Double?
    let pressure: Double?
    let windSpeed: Double?
}

struct Hourly: Decodable {
    let summary: String?
    let icon: String?
    let data: [HourlyData]?
}

struct HourlyData: Decodable {
    let time: Int?
    let summary: String?
    let icon: String?
    let precipIntensity: Double?
    let precipProbability: Double?
    let temperature: Double?
    let apparentTemperature: Double?
    let dewPoint: Double?
    let humidity: Double?
    let pressure: Double?
    let windSpeed: Double?
    let windGust: Double?
    let windBearing: Int?
    let cloudCover: Double?
    let uvIndex: Int?
    let visibility: Double?
    let ozone: Double?
}

struct Daily: Decodable {
    let summary: String?
    let icon: String?
    let data: [DailyData]?
}

struct DailyData: Decodable {
    let time: Int?
    let summary: String?
    let icon: String?
    let sunriseTime: Double?
    let sunsetTime: Double?
    let moonPhase: Double?
    let precipIntensity: Double?
    let precipIntensityMax: Double?
    let precipIntensityMaxTime: Double?
    let precipProbability: Double?
    let temperatureHigh: Double?
    let temperatureHighTime: Double?
    let temperatureLow: Double?
    let temperatureLowTime: Double?
    let apparentTemperatureHigh: Double?
    let apparentTemperatureHighTime: Double?
    let apparentTemperatureLow: Double?
    let apparentTemperatureLowTime: Double?
    let dewPoint: Double?
    let humidity: Double?
    let pressure: Double?
    let windSpeed: Double?
    let windGust: Double?
    let windGustTime: Double?
    let windBearing: Int?
    let cloudCover: Double?
    let uvIndex: Int?
    let uvIndexTime: Double?
    let visibility: Double?
    let ozone: Double?
    let temperatureMin: Double?
    let temperatureMinTime: Double?
    let temperatureMax: Double?
    let temperatureMaxTime: Double?
    let apparentTemperatureMin: Double?
    let apparentTemperatureMinTime: Double?
    let apparentTemperatureMax: Double?
    let apparentTemperatureMaxTime: Double?
}

struct Flags: Decodable {
    let sources: [String]?
    let meteoalarmLicense: String?
    let nearestStation: Double?
    let units: String?
}

extension Currently {
    
    var temperatureString: String? {
        guard let temperatureVal = temperature else { return nil }
        return "\(Int(5 / 9 * (temperatureVal - 32)))˚C"
    }
    
    var pressureString: String? {
        guard let pressureVal = pressure else { return nil }
        return "\(Int(pressureVal * 0.750062)) mm"
    }
    
    var humidityString: String? {
        guard let humidityVal = humidity else { return nil }
        return "\(Int(humidityVal * 100)) %"
    }
    
    var windSpeedString: String? {
        guard let windSpeedVal = windSpeed else { return nil }
        return "\(Int(windSpeedVal)) m/s"
    }
}

extension DailyData {
    
    var sunRiseString: String? {
        guard let sunRiseVal = sunriseTime else { return nil }
        let sunRise = Date(timeIntervalSince1970: sunRiseVal)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: sunRise))"
    }
    
    var sunSetString: String? {
        guard let sunSetVal = sunsetTime else { return nil }
        let sunSet = Date(timeIntervalSince1970: sunSetVal)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: sunSet))"
    }
}
