//
//  Region.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 20/2/21.
//

import Foundation

struct Region: Codable {
    var count: Int
    var next: Int?
    var previous: Int?
    var results: [ResultRegions] = []
}

struct ResultRegions: Codable {
    var name: String
    var url: String
}
