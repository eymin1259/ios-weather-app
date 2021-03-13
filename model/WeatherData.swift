//
//  WeatherData.swift
//  MVC-weather-app
//
//  Created by yongmin lee on 3/5/21.
//

import Foundation

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let description: String
    let main: String
}

// data from server
struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
    let visibility: Int
    
    var model : WeatherModel { // computed property
        
        return WeatherModel(countryName: name,
                            temp: main.temp.toInt(),
                            conditionId: weather.first?.id ?? 0,
                            conditionDescription: weather.first?.description ?? "")
    }
}

// struct allowing to access weather data easily
struct WeatherModel {
    let countryName: String
    let temp : Int
    let conditionId : Int
    let conditionDescription : String
    
    var conditionImage: String {
        
        switch conditionId {
        case 200...299:
            return  "imThunderstorm"
        case 300...399:
            return "imDrizzle"
        case 500...599:
            return "imRain"
        case 600...699:
            return "imSnow"
        case 700...799:
            return "imAtmosphere"
        case 800:
            return "imClear"
        case 801...899:
            return "imClouds"
        default:
            return "imSad"
        }
    }
    
}
