//
//  PokemonArea.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 22/2/21.
//

import Foundation

struct PokemonArea: Codable {
    var id: Int
    var pokemon_encounters: [PokemonEncounter]
}

struct PokemonEncounter: Codable {
    var pokemon: Pokemon
}

struct Pokemon: Codable {
    var name: String
    var url: String
    var selected: Bool? = false

    var dictionary: [String: Any] {
        return [
            "name": name,
            "url": url,
        ]
    }
}
