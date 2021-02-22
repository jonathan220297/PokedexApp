//
//  PokemonPickerViewController.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 22/2/21.
//

import UIKit

protocol PokemonPickerDelegate {
    func pickPokemons(with array: [Pokemon])
}

class PokemonPickerViewController: UIViewController {
    let service = PokedexService()

    @IBOutlet weak var tableViewPokemons: UITableView!

    var urlRegion = ""
    var arrayPokemons: [Pokemon] = []

    var delegate: PokemonPickerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPokemonsRegion()
    }

    // MARK: - Actions
    @IBAction func buttonAddPokemons(_ sender: Any) {
        let pokemonsSelected: [Pokemon] = arrayPokemons.filter { (pokemon) -> Bool in
            pokemon.selected == true
        }
        delegate.pickPokemons(with: pokemonsSelected)
        dismiss(animated: true)
    }

    // MARK: - Functions
    fileprivate func fetchPokemonsRegion() {
        view.activityStarAnimating()
        //First fetch region detail
        let url = urlRegion
        service.callGetWebServiceModel(of: RegionDetail.self, for: url) { (response, error) in
            if let error = error {
                Helpers.debugOnConsole("Error: \(error)")
                self.view.activityStopAnimating()
            } else {
                if let response = response {
                    let group = DispatchGroup()
                    var urlLocationsArea: [String] = []
                    for location in response.locations {
                        group.enter()
                        self.service.callGetWebServiceModel(of: Location.self, for: location.url) { (responseLocation, errLocation) in
                            if let errLocation = errLocation {
                                Helpers.debugOnConsole("Error locations: \(errLocation)")
                                self.view.activityStopAnimating()
                            } else {
                                if let responseLocation = responseLocation {
                                    for area in responseLocation.areas {
                                        urlLocationsArea.append(area.url)
                                    }
                                }
                            }
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        self.fetchPokemonsArea(with: urlLocationsArea)
                    }
                }
            }
        }
    }

    fileprivate func fetchPokemonsArea(with urls: [String]) {
        arrayPokemons.removeAll()
        let group = DispatchGroup()
        for url in urls {
            group.enter()
            self.service.callGetWebServiceModel(of: PokemonArea.self, for: url) { (response, error) in
                if let error = error {
                    Helpers.debugOnConsole("Error Pokemons Areas: \(error)")
                    self.view.activityStopAnimating()
                } else {
                    if let response = response {
                        let uniquePokemons = self.removeDuplicateElements(pokemons: response.pokemon_encounters)
                        for unique in uniquePokemons {
                            var uniqueSaving = unique
                            uniqueSaving.pokemon.selected = false
                            self.arrayPokemons.append(uniqueSaving.pokemon)
                        }
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.view.activityStopAnimating()
            self.tableViewPokemons.reloadData()
        }
    }

    func removeDuplicateElements(pokemons: [PokemonEncounter]) -> [PokemonEncounter] {
        var uniquePokemons = [PokemonEncounter]()
        for pokemon in pokemons {
            if !uniquePokemons.contains(where: {$0.pokemon.name == pokemon.pokemon.name }) {
                uniquePokemons.append(pokemon)
            }
        }
        return uniquePokemons
    }
}

extension PokemonPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPokemons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPokemon", for: indexPath)

        cell.textLabel?.text = arrayPokemons[indexPath.row].name
        if arrayPokemons[indexPath.row].selected! {
            cell.backgroundColor = .lightGray
        } else {
            cell.backgroundColor = .systemBackground
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        arrayPokemons[indexPath.row].selected = !arrayPokemons[indexPath.row].selected!
        let cell = tableView.cellForRow(at: indexPath)
        if arrayPokemons[indexPath.row].selected ?? false {
            cell?.backgroundColor = .lightGray
        } else {
            cell?.backgroundColor = .systemBackground
        }
    }
}
