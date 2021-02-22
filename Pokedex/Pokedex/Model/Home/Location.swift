//
//  Location.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 22/2/21.
//

import Foundation

struct Location: Codable {
    var areas: [Area] = []
}

struct Area: Codable {
    var name: String
    var url: String
}
