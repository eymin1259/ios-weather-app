//
//  Double+Extensions.swift
//  MVC-weather-app
//
//  Created by yongmin lee on 3/5/21.
//

import Foundation


extension Double {
    
    func toString() -> String {
        return String(format: "%.1f", self)
    }
    
    func toInt() -> Int {
        return Int(self)
    }
}
