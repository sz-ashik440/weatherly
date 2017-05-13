//
//  ViewController.swift
//  WeatherLY
//
//  Created by Admin on 5/5/17.
//  Copyright © 2017 c4idiots. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    
    // rediculosness
    @IBOutlet weak var day1Label: UILabel!
    @IBOutlet weak var day1Img: UIImageView!
    @IBOutlet weak var day1Temp: UILabel!
    
    @IBOutlet weak var day2Label: UILabel!
    @IBOutlet weak var day2Img: UIImageView!
    @IBOutlet weak var day2Temp: UILabel!
    
    @IBOutlet weak var day3Label: UILabel!
    @IBOutlet weak var day3Img: UIImageView!
    @IBOutlet weak var day3Temp: UILabel!
    
    @IBOutlet weak var day4Label: UILabel!
    @IBOutlet weak var day4Img: UIImageView!
    @IBOutlet weak var day4Temp: UILabel!
    
    @IBOutlet weak var day5Label: UILabel!
    @IBOutlet weak var day5Img: UIImageView!
    @IBOutlet weak var day5Temp: UILabel!
    
    @IBOutlet weak var day6Label: UILabel!
    @IBOutlet weak var day6Img: UIImageView!
    @IBOutlet weak var day6Temp: UILabel!
    
    @IBOutlet weak var day7Label: UILabel!
    @IBOutlet weak var day7Img: UIImageView!
    @IBOutlet weak var day7Temp: UILabel!
    
    
    
    let BASE_URL = "https://api.darksky.net/forecast"
    
    var locationManager: CLLocationManager = CLLocationManager()
    var counter:Int = 0
    
    let weekDayList = ["SUN", "MON", "TUS", "WED", "THU", "FRI", "SAT"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.distanceFilter = 1000.0*10.0
        
        locationManager.requestLocation()
    }
}

// Location Finder
extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        
        let geoCoder = CLGeocoder()
        
        getCurrentForcast(lat: String(format: "%.6f", lat), long: String(format: "%.6f", long)){ current, dailyData in
            
            geoCoder.reverseGeocodeLocation(location){ (placemarks, error) -> Void in
                let placeMark = placemarks?.first!
                if let locationCity = placeMark?.addressDictionary?["City"] as? String{
                    self.cityLabel.text = locationCity
                }
            }
            
            self.tempLabel.text = String(format:"%0.1f" ,current.temp!) + "˚"
            self.summaryLabel.text = current.summary!
            self.humidityLabel.text = "\(current.humidity!)%"
            
            
            // -------------------------- Daily data --------------------------------------------
            var day = dailyData[0]
            self.day1Label.text = day.day
            self.day1Img.image = UIImage(named: day.icon!)
            self.day1Temp.text = "\(day.minTemp!)˚/\(day.maxTemp!)˚"
            print(day.icon!)
            
            day = dailyData[1]
            self.day2Label.text = day.day
            self.day2Img.image = UIImage(named: day.icon!)
            self.day2Temp.text = "\(day.minTemp!)˚/\(day.maxTemp!)˚"
            print(day.icon!)
            
            day = dailyData[2]
            self.day3Label.text = day.day
            self.day3Img.image = UIImage(named: day.icon!)
            self.day3Temp.text = "\(day.minTemp!)˚/\(day.maxTemp!)˚"
            print(day.icon!)
            
            day = dailyData[3]
            self.day4Label.text = day.day
            self.day4Img.image = UIImage(named: day.icon!)
            self.day4Temp.text = "\(day.minTemp!)˚/\(day.maxTemp!)˚"
            print(day.icon!)
            
            day = dailyData[4]
            self.day5Label.text = day.day
            self.day5Img.image = UIImage(named: day.icon!)
            self.day5Temp.text = "\(day.minTemp!)˚/\(day.maxTemp!)˚"
            print(day.icon!)
            
            day = dailyData[5]
            self.day6Label.text = day.day
            self.day6Img.image = UIImage(named: day.icon!)
            self.day6Temp.text = "\(day.minTemp!)˚/\(day.maxTemp!)˚"
            print(day.icon!)
            
            day = dailyData[7]
            self.day7Label.text = day.day
            self.day7Img.image = UIImage(named: day.icon!)
            self.day7Temp.text = "\(day.minTemp!)˚/\(day.maxTemp!)˚"
            print(day.icon!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// API call
extension ViewController{
    func getCurrentForcast(lat: String, long: String, complition: @escaping (Current, [Daily]) -> Void) {
        
        let current: Current = Current()
        var dailyData = [Daily]()
        
        let url = URL(string: BASE_URL)!
        let urlWithKey = url.appendingPathComponent(API_KEY.darkSky.rawValue)
        let urlWithLatLong = urlWithKey.appendingPathComponent("\(lat),\(long)")
        var urlComponent = URLComponents(url: urlWithLatLong, resolvingAgainstBaseURL: false)!
        urlComponent.queryItems = [
            URLQueryItem(name: "units", value: "si")
        ]
        
        let completeURL = urlComponent.url!
        
        let apiData = URLSession.shared.dataTask(with: completeURL){data, response, error in
            
            guard error == nil,
              let jsonData = data else{
                print(error!.localizedDescription)
                complition(current, dailyData)
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
                
                guard let currently = jsonData["currently"] as? [String:Any],
                    let currentTemp = currently["temperature"] as? Double,
                    let currentIcon = currently["icon"] as? String,
                    let currentSummary = currently["summary"] as? String,
                    let currentHumidity = currently["humidity"] as? Double else {
                        complition(current, dailyData)
                        return
                }
                // print(currentTemp, currentIcon, currentSummary, currentHumidity)
                
                current.temp = currentTemp
                current.icon = currentIcon
                current.summary = currentSummary
                current.humidity = Int(currentHumidity*100)
                
                // print(current.temp, current.icon, current.summary, current.humidity)
                
                // --------------------- Daily forcast data -----------------------------
                
                guard let daily = jsonData["daily"] as? [String: Any],
                    let datas = daily["data"] as? [[String:Any]] else {
                        complition(current, dailyData)
                        return
                }
                
                for data in datas{
                    guard let dailySummary = data["summary"] as? String,
                        let dailyIcon = data["icon"] as? String,
                        let dailyTime = data["time"] as? Int,
                        let dailyTempMax = data["temperatureMax"] as? Double,
                        let dailyTempMin = data["temperatureMin"] as? Double else {
                        return
                    }
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(dailyTime))
                    let calendar = Calendar(identifier: .gregorian)
                    let weekday = calendar.component(.weekday, from: date)
                    
                    // print(dailySummary, dailyIcon, self.weekDayList[weekday-1], dailyTempMax, dailyTempMin)
                    
                    let dailyTemp = Daily()
                    dailyTemp.day = self.weekDayList[weekday-1]
                    dailyTemp.summary = dailySummary
                    dailyTemp.icon = dailyIcon
                    dailyTemp.maxTemp = Int(dailyTempMax)
                    dailyTemp.minTemp = Int(dailyTempMin)
                    
                    dailyData.append(dailyTemp)
                }
                
                DispatchQueue.main.async {
                    complition(current, dailyData)
                }
                
            } catch {
                print(error)
            }
        }.resume()
        
    }
}
