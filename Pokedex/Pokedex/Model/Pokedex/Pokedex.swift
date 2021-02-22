//
//  Pokedex.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 21/2/21.
//

import Foundation
import FirebaseDatabase

struct Pokedex {
    let ref: DatabaseReference?
    let key: String

    var urlImage: String
    var id: String
    var name: String
    var type: String
    var region: Int
    var description: String
    var userUid: String
    var pokemons: [Pokemon]

    init(urlImage: String, id: String, name: String, type: String, region: Int, description: String, key: String = "", userUid: String, pokemons: [Pokemon] = []) {
        self.ref = nil
        self.key = key
        self.urlImage = urlImage
        self.id = id
        self.name = name
        self.type = type
        self.region = region
        self.description = description
        self.userUid = userUid
        self.pokemons = pokemons
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let description = value["description"] as? String,
            let id = value["id"] as? String,
            let name = value["name"] as? String,
            let region = value["region"] as? Int,
            let type = value["type"] as? String,
            let urlImage = value["urlImage"] as? String,
            let userUid = value["userUid"] as? String,
            let pokemons = value["pokemons"] as? [[String: Any]] else {
            return nil
        }

        self.ref = snapshot.ref
        self.key = snapshot.key
        self.description = description
        self.id = id
        self.name = name
        self.region = region
        self.type = type
        self.urlImage = urlImage
        self.userUid = userUid
        self.pokemons = []
        for pokemon in pokemons {
            let pokemonSave = Pokemon(name: pokemon["name"] as! String, url: pokemon["url"] as! String, selected: true)
            self.pokemons.append(pokemonSave)
        }
    }

    var dictionary: [String: Any] {
        var pokemonsDict: [[String: Any]] = []
        for pokemon in pokemons {
            pokemonsDict.append(["name": pokemon.name, "url": pokemon.url])
        }
        return [
            "urlImage": urlImage,
            "id": id,
            "name": name,
            "type": type,
            "description": description,
            "region": region,
            "userUid": userUid,
            "pokemons": pokemonsDict
        ]
    }
}
