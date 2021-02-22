//
//  Constants.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 19/2/21.
//

import Foundation
import UIKit
import Alamofire

let AlamofireSessionManager: Alamofire.Session = {
    let configuration = URLSessionConfiguration.default
    return Alamofire.Session(configuration: configuration)
}()

enum PokedexAction {
    case detail
    case add
    case editing
}

struct Storyboards {
    static let Auth: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    static let Home: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
    static let Pokedex: UIStoryboard = UIStoryboard(name: "Pokedex", bundle: nil)
}

struct ConfigApp {
    static let MODE_DEVELOPER = true
}

struct Constants {
    struct URL {
        static var main = "https://pokeapi.co/api/v2/"
    }

    struct Endpoints {
        static var regions = "region"
    }

    static var userID = ""
}
