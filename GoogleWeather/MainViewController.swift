//
//  MainViewController.swift
//  GoogleWeather
//
//  Created by Frederick C. Lee on 2/6/18.
//  Copyright © 2018 Amourine Technologies. All rights reserved.
//

import UIKit

protocol AvailableOptions {
    var availableOptions: [Options] {get}
}

protocol OptionProtocol {
    var optionList: OptionsStruct? {get}
}

protocol OptionListProtocol: OptionProtocol {
    func addOptionList()
    func setupNotification()
}

let optionNotification = Notification.Name(rawValue: "optionNotification")

enum Options: Int {
    case NewYork
    case London
    case Tokyo
    case cancel
    func description() -> String {
        switch self {
        case .NewYork:
            return "New York"
        case .London:
            return "London"
        case .Tokyo:
            return "Tokyo"
        case .cancel:
            return "Cancel"
        }
    }
    func doSomething() {
        switch self {
        case .NewYork:
            print("Do Something with New York.")
        case .London:
            print("Do Something with London.")
        case .Tokyo:
            print("Do Something with Tokyo.")
        default:
            break
        }
    }
}

struct OptionsStruct: AvailableOptions {
    var availableOptions = [Options]()
    var title = String()
    init(title: String, options: [Options]) {
        self.title = title;
        var myOptions = options
        myOptions.append(.cancel)
        self.availableOptions = myOptions
    }
}

// ===================================================================================================

class MainViewController: UIViewController {
    var optionList: OptionsStruct?
    
    var cityInfo:(name:String, temp:String, desc:String) = ("","","")  {
        didSet {
            setupUI()
        }
    }
    
    // MARK: - Initial Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Google Weather"
        view.backgroundColor = UIColor.skyBlue()
        setupUI(buttonOnly: true)
        setupNotification()
        addOptionList()
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    func setupUI(buttonOnly: Bool = false) {
        let palatinoFont = "Palatino"
        let topBuffer = CGFloat(80.0)
        
        if buttonOnly {
            // City Selector:.
            let cityButton:UIButton = {
                let button = UIButton(type: UIButtonType.system)
                button.setTitle("Pick City", for: .normal)
                button.titleLabel?.textColor = UIColor.purple
                button.titleLabel?.font = UIFont(name: palatinoFont, size: 18.0)
                button.titleLabel?.textAlignment = .center
                button.addTarget(self, action: #selector(getWeatherData), for: .touchUpInside)
                return button
            }()
            view.addSubview(cityButton)
            cityButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              bottom: nil,
                              left: nil,
                              right: nil,
                              centerYAnchor: nil,
                              centerXAnchor: view.safeAreaLayoutGuide.centerXAnchor,
                              paddingTop: topBuffer + 120,
                              paddingLeft: 0,
                              paddingBottom: 10,
                              paddingRight: 10, width: 150, height: 32)
        } else {
            // City Label:
            let cityLable:UILabel = {
                let label = UILabel()
                label.text = cityInfo.name
                label.textColor = UIColor.purple
                label.font = UIFont(name: palatinoFont, size: 21.0)
                label.textAlignment = .center
                return label
            }()
            
            // Weather at City:
            let weatherLable:UILabel = {
                let label = UILabel()

                label.text = "\(cityInfo.temp)C with \(cityInfo.desc)"
                label.textColor = UIColor.purple
                label.font = UIFont(name: palatinoFont, size: 18.0)
                label.textAlignment = .center
                return label
            }()
            
            view.addSubview(cityLable)
            cityLable.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             bottom: nil,
                             left: nil,
                             right: nil,
                             centerYAnchor: nil,
                             centerXAnchor: view.safeAreaLayoutGuide.centerXAnchor,
                             paddingTop: topBuffer,
                             paddingLeft: 0,
                             paddingBottom: 10,
                             paddingRight: 10, width: 0.0, height: 24)
            
            view.addSubview(weatherLable)
            weatherLable.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                bottom: nil,
                                left: nil,
                                right: nil,
                                centerYAnchor: nil,
                                centerXAnchor: view.safeAreaLayoutGuide.centerXAnchor,
                                paddingTop: topBuffer + 40,
                                paddingLeft: 0,
                                paddingBottom: 10,
                                paddingRight: 10, width: 0.0, height: 24)
        }
        
    }
    
    // -----------------------------------------------------------------------------------------------------
    // MARK: - Action Method
    
    @objc func getWeatherData() {
        let weatherURIString = "http://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=b6907d289e10d714a6e88b30761fae22"
        let url = URL(string:weatherURIString)
        
        let weatherResource = WeatherResource(url: url!) {(data) -> Data? in
            return data
        }
        
        WeatherService().load(resource: weatherResource) {result in
            DispatchQueue.main.async(execute: {
                if let errorDescription = result as? String {
                    print(errorDescription)
                } else if let jsonData = result as? Data {
                    let weatherData = self.disseminateJSON(data: jsonData)
                    if let name = weatherData?.name,
                        let temp = weatherData?.main.temp,
                        let weatherDesc = weatherData?.weather[0].description {
                        let kelvinConversion = Float(273.15)
                        let celsius = NSNumber(value:Float(temp) - kelvinConversion)
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        formatter.maximumFractionDigits = 2
                        if let celsiusString = formatter.string(from: celsius) {
                            self.cityInfo = (name, celsiusString, weatherDesc)
                        }
                    }
                }
            })
        }
    }
}

// ===================================================================================================
// MARK: -

extension MainViewController {
    
    public struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    public struct Main: Codable {
        let temp: Float
        let pressure: Float
        let humidity: Float
        let temp_min: Float
        let temp_max: Float
    }
    
    public struct Wind: Codable {
        let speed: Float
        let deg: Float
    }
    
    public struct Clouds: Codable {
        let all: Int
    }
    
    public struct Sys: Codable {
        let type: Int
        let id: Int
        let message: Double
        let country: String
        let sunrise: Double
        let sunset: Double
    }
    
    struct DataListModel: Codable {
        let coord : [String:Float]
        let weather : [Weather]
        let base: String
        let main: Main
        let visibility: Double
        let wind: Wind
        let clouds: [String:Int]
        let dt: Double
        let sys: Sys
        let id: Int
        let name: String
        let cod: Int
    }
    
    func disseminateJSON(data: Data) -> DataListModel? {
        var weatherStuff:DataListModel?
        do {
            weatherStuff = try JSONDecoder().decode(DataListModel.self, from: data)
        } catch let error as NSError {
            let title = "JSON Dissemination Error"
            let alert = UIAlertController(title: title, message: error.debugDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return weatherStuff
    }
}

// ===================================================================================================

extension MainViewController: OptionListProtocol {
    func setupNotification() {
        NotificationCenter.default.addObserver(forName: optionNotification, object: nil, queue: nil) { (note) in
            if let childVC = note.userInfo?["sender"] {
                if let controller = childVC as? GoogleTableViewController {
                    controller.willMove(toParentViewController: nil)
                    var transform = CGAffineTransform(scaleX: 1, y: -1)
                    transform = transform.translatedBy(x: 0, y: -controller.view.frame.size.height)
                    UIView.animate(withDuration: 0.5, animations: {
                        controller.view.transform = transform
                    }, completion: { (completed) in
                        controller.view.removeFromSuperview()
                    })
                    
                    controller.removeFromParentViewController()
                }
            }
            if let option = note.object as? Int,
                let selectedOption = Options(rawValue: option) {
                selectedOption.doSomething()
            }
        }
    }
    
    func addOptionList() {
        optionList = OptionsStruct(title: "Cities of Weather", options: [.NewYork, .London, .Tokyo])
        guard let count = optionList?.availableOptions.count else {
            return
        }
        
        let controller = GoogleTableViewController()
        controller.optionList = optionList
        let heightConstant = controller.tableView.rowHeight * CGFloat(count + 2)
        
        self.addChildViewController(controller)
        view.addSubview(controller.view)
        
        controller.view.anchor(top: nil,
                               bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               left: view.safeAreaLayoutGuide.leftAnchor,
                               right: view.safeAreaLayoutGuide.rightAnchor,
                               centerYAnchor: nil,
                               centerXAnchor: nil,
                               paddingTop: heightConstant,
                               paddingLeft: 0,
                               paddingBottom: 52,
                               paddingRight: 10, width: 0.0, height: heightConstant)
        
        
        controller.didMove(toParentViewController: self)
    }
}

