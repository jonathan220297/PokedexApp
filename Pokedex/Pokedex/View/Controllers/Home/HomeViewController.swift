//
//  HomeViewController.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 19/2/21.
//

import UIKit

class HomeViewController: UIViewController {
    let service = PokedexService()

    @IBOutlet weak var tableViewRegions: UITableView!

    var arrayRegions: [ResultRegions] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchRegions()
    }

    // MARK: - Functions
    fileprivate func fetchRegions() {
        let url = Constants.URL.main+Constants.Endpoints.regions
        service.callGetWebServiceModel(of: Region.self, for: url) { [self] (response, err) in
            if let err = err {
                showAlert(alertText: "Pokedex", alertMessage: err)
            } else {
                if let response = response {
                    arrayRegions = response.results
                }
            }
            tableViewRegions.reloadData()
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pokedexTVC = Storyboards.Pokedex.instantiateViewController(withIdentifier: "pokedexTVC") as! PokedexTableViewController
        if let idStr = arrayRegions[indexPath.row].url.split(separator: "/").last,
           let id = Int(idStr) {
            pokedexTVC.id = id
        }
        pokedexTVC.urlRegion = arrayRegions[indexPath.row].url
        navigationController?.pushViewController(pokedexTVC, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Regions"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayRegions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRegions", for: indexPath)

        cell.textLabel?.text = arrayRegions[indexPath.row].name

        return cell
    }
}
