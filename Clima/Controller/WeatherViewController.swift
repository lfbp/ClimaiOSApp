//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var citySearchInputField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    
    var weatherAPI = WeatherAPI()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        citySearchInputField.delegate = self
        searchButton.addTarget(self, action: #selector(searchCityName), for: .touchUpInside)
        weatherAPI.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @objc func searchCityName() {
        if let locationName = citySearchInputField.text, !locationName.isEmpty {
            searchFor(locationName)
            cleanAndEndTextField()
        }
    }
    
    private func searchFor(_ cityName: String) {
        print("Searching data for \(cityName)")
        weatherAPI.getWeatherData(city: cityName  )
    }
    
    private func updateUI(weatherModel: WeatherModel) {
        DispatchQueue.main.async {
            print("Updating UI: \(weatherModel.cityName), \(weatherModel.tempereature), \(weatherModel.conditionName)")
            self.temperatureLabel.text = String(format: "%.1f", weatherModel.tempereature)
            self.conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
            self.cityLabel.text = weatherModel.cityName
        }
    }
    private func cleanAndEndTextField() {
        citySearchInputField.endEditing(true)
        citySearchInputField.text = ""
        citySearchInputField.placeholder = "Search"
    }
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager.requestLocation()
    }
}

extension WeatherViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if let locationName = textField.text {
            if locationName.isEmpty {
                print("Empty search string")
                textField.placeholder = "Search a location..."
                return false
            } else {
                searchFor(locationName)
                cleanAndEndTextField()
                return true
            }
        }
        
        return false
    }
}

extension WeatherViewController: WeatherAPIProtocol {
    func didGetResponse(with model: WeatherData) {
        let model = WeatherModel(
            conditionID: model.weather.first?.id ?? 0,
            cityName: model.name,
            tempereature: model.main.temp
        )
        updateUI(weatherModel: model)
    }
    
    func didGetParsingError(with error: Error) {
        print("Data Parsing Error: \(error.localizedDescription)")
    }
    
    func urlParsingError(url: String) {
        print("URL parsing error for url: \(url)")
    }
    
    func didGetResponseError(_ error: Error) {
        print("Response with error: \(error)")
    }
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update location")
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherAPI.getWeatherData(latitue: lat, longitude: lon)
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }
}

