//
//  PokedexService.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 20/2/21.
//

import Foundation
import Alamofire

class PokedexService {
    func callPostWebServiceModel<T: Decodable>(of type: T.Type = T.self, for url: String, with parameters: [String: Any], completion: @escaping(_ result: T?, _ error: String?) -> ()) {
        Helpers.debugOnConsole("URL: \(url)")
        Helpers.debugOnConsole("Parameters: \(parameters)")
        AlamofireSessionManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            if let error = response.error {
                Helpers.debugOnConsole("Error while callWebServicesModel info: \(error.localizedDescription)")
                completion(nil, "Unknown error.")
                return
            }
            guard let data = response.data else {return completion(nil, "Unknown error.")}
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(response, nil)
            } catch let error as NSError {
                Helpers.debugOnConsole("Error while parsing callWebServicesModel: \(error.localizedDescription)")
                completion(nil, "Unknown error.")
            }
        }
    }

    func callGetWebServiceModel<T: Decodable>(of type: T.Type = T.self, for url: String, completion: @escaping(_ result: T?, _ error: String?) -> ()) {
        Helpers.debugOnConsole("URL: \(url)")
        AlamofireSessionManager.request(url, method: .get).responseJSON { (response) in
            if let error = response.error {
                Helpers.debugOnConsole("Error while callWebServicesModel info: \(error.localizedDescription)")
                completion(nil, "Unknown error.")
                return
            }
            guard let data = response.data else {return completion(nil, "Unknown error.")}
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(response, nil)
            } catch let error as NSError {
                Helpers.debugOnConsole("Error while parsing callWebServicesModel: \(error.localizedDescription)")
                completion(nil, "Unknown error.")
            }
        }
    }
}
