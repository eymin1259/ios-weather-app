//
//  addCityViewController.swift
//  MVC-weather-app
//
//  Created by yongmin lee on 3/8/21.
//

import UIKit


class AddCityViewController: UIViewController {
    
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var citySearchBtn: UIButton!
    @IBOutlet var activityIncatorView: UIActivityIndicatorView!
    @IBOutlet var statusLabel: UILabel!
    
    private let weatherManager = WeatherManager()
    
    weak var delegate: WeatherViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cityTextField.becomeFirstResponder()
        
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        statusLabel.isHidden = true
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        
        // extension AddCityViewController: UIGestureRecognizerDelegate
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchBtnTap(_ sender: Any) {
        statusLabel.isHidden = true
        guard let query = cityTextField.text, !query.isEmpty else {
            // text field 가 비어있으면 종료
            showSearchError(text: "city cannot be empty")
            return }
        
        searchForCity(query: query)
    }
    
    private func showSearchError(text:String){
      
        statusLabel.textColor = .red
        statusLabel.text = text
        statusLabel.isHidden = false
    }
    
    private func searchForCity(query: String) {
        
        view.endEditing(true)
        activityIncatorView.startAnimating()
        weatherManager.fetchWeather(city: query) { (result) in
            self.activityIncatorView.stopAnimating()
            switch result {
            case .success(let model):
                self.handleSearchSuccess(model: model)
            case .failure(let error):
                self.showSearchError(text: error.localizedDescription)
            
            }
            
            
        }
        
    }
    
    private func handleSearchSuccess(model: WeatherModel){
        print(model.countryName)
        statusLabel.isHidden = false
        statusLabel.textColor = .green
        statusLabel.text = "success"
        
        // response 수신후 view update 0.5초 지연
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.delegate?.didUpdateWeatherFromSearch(model: model)
        }
        
    }
    
}

extension AddCityViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        // 터치한 영역이 viewController의 자식 view이어야만 gesture 인식
        // -> stack view 터치한 경우 gesture 인식안되어 dismiss view controller 실행 x
        return touch.view == self.view
    }
}
