//
//  WeatherAPI.swift
//  Clima
//
//  Created by lpereira on 01/08/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherAPIProtocol {
    func didGetResponse(with model: WeatherData)
    func didGetParsingError(with error:Error)
    func urlParsingError(url: String)
    func didGetResponseError(_ error: Error)
}

struct WeatherAPI {
    
     private let key = "57bf63e73c5588622bb6850ab77ac880"
     private let baseURL = "https://api.openweathermap.org/data/2.5/weather?"
     var delegate: WeatherAPIProtocol?
    
     func getWeatherData(city name: String) {
        let cleanedLocation = cleanString(name)
        let url = "\(baseURL)appid=\(key)&q=\(cleanedLocation)&units=metric"
        print("Calling API: \(url)")
        fetch(path: url)
    }
    
    func getWeatherData(latitue: CLLocationDegrees, longitude: CLLocationDegrees) {
       let url = "\(baseURL)appid=\(key)&units=metric&lat=\(latitue)&lon=\(longitude)"
       print("Calling API: \(url)")
       fetch(path: url)
   }
    private func cleanString (_ value: String) -> String {
        return value
    }
    
    private func fetch(path: String) {
        
        if let url = URL(string:  path) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url, completionHandler: {
                data, response, error in
                if let error = error {
                    delegate?.didGetResponseError(error)
                } else if let data = data {
                    self.decodeDataToModel(data)
                }
            })
            task.resume()
        } else {
            delegate?.urlParsingError(url: path)
        }
    }
    
    func decodeDataToModel (_ data: Data) {
        do {
            let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
            delegate?.didGetResponse(with: decodedData)
        } catch {
            delegate?.didGetParsingError(with: error)
        }
    }
}
