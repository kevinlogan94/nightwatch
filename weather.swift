//
//  structSample.swift
//  Night Watch
//
//  Created by Logan, Kevin on 10/8/18.
//  Copyright © 2018 Kevin M Logan. All rights reserved.
//

import Foundation

struct Weather: Decodable {
    
    struct mainInfo: Decodable {
        let temp: Float;
        let temp_min: Float;
        let temp_max: Float;
        let pressure: Float;
        let sea_level: Float;
        let grnd_level: Float;
        let humidity: Int;
        let temp_kf: Float;
    }
    
    struct weatherInfo: Decodable {
        let id: Int;
        let main: String;
        let description: String;
    }
    
    struct cloudInfo: Decodable {
        let all: Int;
    }
    
    struct windInfo: Decodable {
        let speed: Float;
        let deg: Float;
    }
    
    struct dailyWeather: Decodable {
        let dt: Int;
        let main: mainInfo;
        let weather: [weatherInfo];
        let clouds: cloudInfo;
        let wind: windInfo;
        let dt_txt: String;
    }
    
    let cod: String;
    let message: Float;
    let cnt: Int;
    let list: [dailyWeather];
    
    // --------- Only need this in Swift 2/3 ---------
    //    init(json: [String: Any]) {
    //        cod = json["cod"] as? String ?? "";
    //        message = json["message"] as? Float ?? -1;
    //        cnt = json["cnt"] as? Int ?? -1;
    //
    //    }
}
