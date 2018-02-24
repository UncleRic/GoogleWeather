//
//  WeatherService.swift
//  GoogleWeather
//
//  Created by Frederick C. Lee on 2/7/18.
//  Copyright © 2018 Amourine Technologies. All rights reserved.
//

import UIKit

struct WeatherResource {
    let url:URL
    let parse:(Data) -> Data?
}

final class WeatherService {
    final func load(resource: WeatherResource, completion: @escaping (Any?) -> Void) {
        URLSession.shared.dataTask(with: resource.url) { (data, _, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else if let data = data {
                completion(data)
            } else {
                completion(nil)
            }
            }.resume()
    }
}


















