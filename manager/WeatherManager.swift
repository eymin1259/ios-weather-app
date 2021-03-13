//
//  WeatherManager.swift
//  MVC-weather-app
//
//  Created by yongmin lee on 3/5/21.
//

import Foundation
import Alamofire

// custom error
enum WeatherError: Error, LocalizedError {
    
    case unknown
    case custom(msg: String)
    
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "this is unknown error"
        case .custom(let msg):
            return msg
        }
    }
}

struct WeatherManager {
    
    private let API_KEY = "e1aaa6a36ef48730a705585df12156f5"
    
    func fetchWeather(city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let path = "http://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: path, query, API_KEY)
        
        AF.request(urlString).validate().responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) {(response) in
            switch response.result {
            case .success(let weatherData):
                let model = weatherData.model
                
                completion(.success(model)) // pass weather data to view controller
                
            case .failure(let error):
   
                // if error from server is parsable
                if error.responseCode == 404, let data = response.data, let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
                    let message = failure.message
                    
                    // pass error msg from server
                    completion(.failure(WeatherError.custom(msg: message)))
                }else{
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchWeather(latitude: Double, longitude:Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        
        let path = "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%@"
        let urlString = String(format: path, latitude, longitude ,API_KEY)
        
        AF.request(urlString).validate().responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) {(response) in
            switch response.result {
            case .success(let weatherData):
                let model = weatherData.model
                
                completion(.success(model)) // pass weather data to view controller
                
            case .failure(let error):
   
                // if error from server is parsable
                if error.responseCode == 404, let data = response.data, let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
                    let message = failure.message
                    
                    // pass error msg from server
                    completion(.failure(WeatherError.custom(msg: message)))
                }else{
                    completion(.failure(error))
                }
            }
        }
    }
}
