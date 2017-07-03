//
//  ViewController.swift
//  WeatherLY
//
//  Created by Admin on 5/5/17.
//  Copyright © 2017 c4idiots. All rights reserved.
//

import UIKit
import CoreLocation
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherStackview: UIStackView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var minMaxLabel: UILabel!
    @IBOutlet weak var dailyChart: LineChartView!
    
    @IBOutlet weak var dailyCollectionView: UICollectionView!
    
    let BASE_URL = "https://api.darksky.net/forecast"
    
    var locationManager: CLLocationManager = CLLocationManager()
    var counter:Int = 0
    
    let weekDayList = ["SUN", "MON", "TUS", "WED", "THU", "FRI", "SAT"]
    
    var dailyWeather: [Daily] = []
    
    var hourlyWeather: [Hourly] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyCollectionView.delegate = self
        dailyCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.distanceFilter = 1000.0*10.0
        
        locationManager.requestLocation()
    }
}

// MARK:- Location Finder
extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let lat = String(format: "%.6f", location.coordinate.latitude)
        let long = String(format: "%.6f",  location.coordinate.longitude)
        
        let geoCoder = CLGeocoder()
        
        getCurrentForcast(lat: lat, long: long) { current, dailyData, hourlyData in
            
            DispatchQueue.main.async {
                geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
                    let placeMark = placemarks?.first!
                    if let locationCity = placeMark?.addressDictionary?["City"] as? String{
                        self.cityLabel.text = locationCity
                    }
                }
            }
            
            self.tempLabel.text = String(format:"%0.1f" ,current.temp!) + "˚"
            self.summaryLabel.text = current.summary!
            self.humidityLabel.text = "\(current.humidity!)%"
            let currentDay = dailyData[0]
            self.minMaxLabel.text = "\(currentDay.minTemp!)˚/\(currentDay.maxTemp!)˚"
            // print(dailyData.count)
            
            // print(hourlyData.count)
            UIView.animate(withDuration: 0.8) {
                self.weatherStackview.isHidden = false
            }
            
            self.dailyWeather = dailyData
            self.dailyCollectionView.reloadData()
            let hourlyData12 = Array(hourlyData[0...11])
            self.drawChart(hourlyData: hourlyData12)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func drawChart(hourlyData: [Hourly]) {
        
        let temps = hourlyData.map {$0.temp!}
        
        let times = hourlyData.map { (hourlyObj) -> String in
            let date = Date(timeIntervalSince1970: TimeInterval(hourlyObj.time!))
            let timePeriodFormatter = DateFormatter()
            timePeriodFormatter.dateFormat = "hh:mm"
            let timeString = timePeriodFormatter.string(from: date)
            return timeString
        }
        // print(times.count)
        
        var entries: [ChartDataEntry] = []
        
        for i in 0..<hourlyData.count{
            // entries.append(ChartDataEntry(x: Double(data.time!), y: data.temp!))
            entries.append(ChartDataEntry(x: Double(i), y: (hourlyData[i].temp)!))
        }
        
        
        //----------------------------- dataset intensified ---------------------------------------
        let dataset = LineChartDataSet(values: entries, label: nil)
        dataset.axisDependency = .left
        dataset.colors = [.orange]
        dataset.mode = .cubicBezier
        dataset.cubicIntensity = 0.1
        
        // kicked out circlre from line
        dataset.drawCirclesEnabled = false
        
        dataset.lineWidth = 2.0
        dataset.fillAlpha = 100
        dataset.drawFilledEnabled = true
        dataset.fillColor = UIColor.orange
        dataset.highlightColor = UIColor.brown
        
        dataset.valueColors = [.white]
        
        dataset.drawValuesEnabled = false
        
        
        dailyChart.noDataText = ""
        
        let chartFormatter = LineChartFormatter(labels: times)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        
        dailyChart.xAxis.valueFormatter = xAxis.valueFormatter
        
        let data = LineChartData()
        data.addDataSet(dataset)
        
        dailyChart.data = data
        
        // removing background gridline and border
        dailyChart.drawGridBackgroundEnabled = false
        dailyChart.drawBordersEnabled = false
        
        // removing vertical and horizontal lines
        dailyChart.xAxis.drawGridLinesEnabled = false
        dailyChart.leftAxis.drawGridLinesEnabled = false
        
        
        dailyChart.leftAxis.enabled = true
        dailyChart.leftAxis.labelPosition = .insideChart
        
        dailyChart.leftAxis.granularityEnabled = true
        dailyChart.leftAxis.granularity = 2.0
        dailyChart.leftAxis.axisMinimum = temps.min()! - 1.0
        dailyChart.leftAxis.axisMaximum = temps.max()! + 2.0
        
        dailyChart.rightAxis.enabled = false
        
        dailyChart.chartDescription?.text = ""
        dailyChart.legend.enabled = false
        dailyChart.xAxis.labelPosition = .bottom
        
        dailyChart.xAxis.labelTextColor = .white
        dailyChart.leftAxis.labelTextColor = .white
        
        dailyChart.animate(xAxisDuration: 1.2, yAxisDuration: 1.2)
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dailyWeather.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DailyCollectionViewCell
        
        let tempWeather = self.dailyWeather[indexPath.row+1]
        cell.weekDayLabel.text = tempWeather.day
        cell.weatherIcon.image = UIImage(named: tempWeather.icon!)
        cell.tempLabel.text = "\(tempWeather.minTemp!)˚/\(tempWeather.maxTemp!)˚"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/8 - 2, height: 110)
    }
}





// API call
extension ViewController{
    func getCurrentForcast(lat: String, long: String, complition: @escaping (Current, [Daily], [Hourly]) -> Void) {
        
        let current: Current = Current()
        var dailyData: [Daily] = []
        var hourlyData: [Hourly] = []
        
        let url = URL(string: BASE_URL)!
        let urlWithKey = url.appendingPathComponent(API_KEY.darkSky.rawValue)
        let urlWithLatLong = urlWithKey.appendingPathComponent("\(lat),\(long)")
        var urlComponent = URLComponents(url: urlWithLatLong, resolvingAgainstBaseURL: false)!
        urlComponent.queryItems = [
            URLQueryItem(name: "units", value: "si")
        ]
        
        let completeURL = urlComponent.url!
        
        URLSession.shared.dataTask(with: completeURL) { data, response, error in
            
            guard error == nil,
              let data = data else{
                print(error!.localizedDescription)
                complition(current, dailyData, hourlyData)
                return
            }
            
            var jsonData: [String: Any] = [:]
            
            do {
                jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            } catch {
                print(error)
                complition(current, dailyData, hourlyData)
                return
            }
            
            guard let currently = jsonData["currently"] as? [String:Any],
                let currentTemp = currently["temperature"] as? Double,
                let currentIcon = currently["icon"] as? String,
                let currentSummary = currently["summary"] as? String,
                let currentHumidity = currently["humidity"] as? Double else {
                    complition(current, dailyData, hourlyData)
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
                    complition(current, dailyData, hourlyData)
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
                
                // print(calendar.component(.day , from: date))
                
                // print(dailySummary, dailyIcon, self.weekDayList[weekday-1], dailyTempMax, dailyTempMin)
                // print(weekday)
                let dailyTemp = Daily()
                dailyTemp.day = self.weekDayList[weekday-1]
                dailyTemp.summary = dailySummary
                dailyTemp.icon = dailyIcon
                dailyTemp.maxTemp = Int(dailyTempMax)
                dailyTemp.minTemp = Int(dailyTempMin)
                
                dailyData.append(dailyTemp)
            }
            
            // --------------------- Hourly forcast data -----------------------------
            
            guard let hourly = jsonData["hourly"] as? [String: Any],
                let hourlyDatas = hourly["data"] as? [[String: Any]] else {
                return
            }
            
            for data in hourlyDatas{
                
                guard let hourlyTime = data["time"] as? Int,
                    let hourlyTemp = data["temperature"] as? Double,
                    let hourlyApperentTemp = data["apparentTemperature"] as? Double else {
                    return
                }
                
                // print(hourlyTime, hourlyTemp, hourlyApperentTemp)
                
                let hourlyObj = Hourly()
                hourlyObj.time = hourlyTime
                hourlyObj.temp = hourlyTemp
                hourlyObj.apperentTemp = hourlyApperentTemp
                
                hourlyData.append(hourlyObj)
            }
            
            DispatchQueue.main.async {
                complition(current, dailyData, hourlyData)
            }
        }.resume()
    }
}



