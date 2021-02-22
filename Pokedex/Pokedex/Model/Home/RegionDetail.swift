//
//  RegionDetail.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 22/2/21.
//

import Foundation

struct RegionDetail: Codable {
    var id: Int
    var locations: [LocationRegion] = []
}

struct LocationRegion: Codable {
    var name: String
    var url: String
}
