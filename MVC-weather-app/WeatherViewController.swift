//
//  ViewController.swift
//  MVC-weather-app
//
//  Created by yongmin lee on 3/4/21.
//

import UIKit
import SkeletonView
import CoreLocation
import Loaf

protocol WeatherViewControllerDelegate : class{
    func didUpdateWeatherFromSearch(model: WeatherModel)
}


class WeatherViewController: UIViewController {

    @IBOutlet var conditionImageView: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    
    private let weatherManager = WeatherManager()
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchweather(city: "paris")
        
    }
    
    private func fetchWeather(location: CLLocation){
        showAnimation()
        let latitude = location.coordinate.latitude   // 위도
        let longitude = location.coordinate.longitude // 경도
        weatherManager.fetchWeather(latitude: latitude, longitude: longitude) { (result) in
            self.handleFetchResult(result: result)
        }
    }
    
    private func fetchweather(city: String) {
        showAnimation()
        weatherManager.fetchWeather(city: city) { (result) in
            self.handleFetchResult(result: result)
        }
    }
    
    private func handleFetchResult(result: Result<WeatherModel,Error> ) {
        switch result {
        case .success(let weathermodel):
            updateView(with: weathermodel)
        case .failure(let error):
            handleError(error: error)
        }
    }
    
    private func handleError(error: Error){
        conditionImageView.hideSkeleton()
        conditionImageView.image = UIImage(named: "imSad")
        temperatureLabel.hideSkeleton()
        temperatureLabel.text = "Ooops"
        conditionLabel.hideSkeleton()
        conditionLabel.text = "Something went wrong. Please try again"
        navigationItem.title = ""
        Loaf(error.localizedDescription, state: .error, location: .top, sender: self).show()
    }
    
    private func updateView(with data: WeatherModel) {
        conditionImageView.hideSkeleton()
        conditionImageView.image = UIImage(named: data.conditionImage)
        temperatureLabel.hideSkeleton()
        temperatureLabel.text = data.temp.toString().appending("°C")
        conditionLabel.hideSkeleton()
        conditionLabel.text = data.conditionDescription
        navigationItem.title = data.countryName
        
    }
    
    private func showAnimation(){
        
        conditionImageView.showAnimatedGradientSkeleton()
        temperatureLabel.showAnimatedGradientSkeleton()
        conditionLabel.showAnimatedGradientSkeleton()
        
    }
    
    @IBAction func locationBtnTab(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        default:
            promptForLocationPermission()
        }
    }
    
    private func promptForLocationPermission() {
        let alertController = UIAlertController(title: "require location permission", message: "would you like to enable location permission?", preferredStyle: .alert)
        
        let enableAction = UIAlertAction(title: "go to settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    

    @IBAction func addCityBtnTab(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }
}

extension WeatherViewController : WeatherViewControllerDelegate {
    func didUpdateWeatherFromSearch(model: WeatherModel) {
        presentedViewController?.dismiss(animated: true, completion: {
            self.updateView(with: model)
        })
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    // 84, 87 줄 locationManager.requestLocation() 실행이후 호출되는 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            self.fetchWeather(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error: error)
    }
}
