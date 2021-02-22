//
//  PokedexTableViewController.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 20/2/21.
//

import UIKit
import FirebaseDatabase

class PokedexTableViewController: UITableViewController {

    var id = 0
    var urlRegion = ""

    var ref: DatabaseReference!

    var arrayPokedex: [Pokedex] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference(fromURL: "https://pokedex-13e5e-default-rtdb.firebaseio.com/")
        navigationItem.title = "Pokedex"
        Helpers.debugOnConsole("Id: \(id)")

        let buttonAddPokedex = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(buttonAddPokedexTapped))
        buttonAddPokedex.tintColor = .white
        navigationItem.rightBarButtonItem = buttonAddPokedex

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchPokedexList()
    }

    // MARK: - Observers
    @objc func buttonAddPokedexTapped() {
        let addPokedexVC = Storyboards.Pokedex.instantiateViewController(withIdentifier: "addPokedexVC") as! AddPokedexViewController
        addPokedexVC.region = id
        addPokedexVC.provenance = .add
        addPokedexVC.urlRegion = urlRegion
        self.navigationController?.pushViewController(addPokedexVC, animated: true)
    }

    // MARK: - Functions
    fileprivate func fetchPokedexList() {
        view.activityStarAnimating()
        let pokedexRef = ref.child("Pokedex")
            .queryOrdered(byChild: "region")
            .queryEqual(toValue: id)
        pokedexRef.observeSingleEvent(of: .value) { (snapshot) in
            self.view.activityStopAnimating()
            var pokedexes: [Pokedex] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let pokedex = Pokedex(snapshot: snapshot) {
                    pokedexes.append(pokedex)
                }
            }
            self.arrayPokedex = pokedexes.filter({ (pokedex) -> Bool in
                pokedex.userUid == Constants.userID
            })
            self.tableView.reloadData()
        }
        
    }

    fileprivate func deleteRow(with key: String, at indexPath: IndexPath) {
        ref.child("Pokedex")
            .child(key)
            .removeValue { [self] (error, reference) in
                if error == nil {
                    arrayPokedex.remove(at: indexPath.row)
                    tableView.reloadData()
                }
            }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayPokedex.count == 0 {
            self.tableView.setEmptyMessage("No data")
        } else {
            self.tableView.restore()
        }

        return arrayPokedex.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPokedex", for: indexPath)

        cell.textLabel?.text = arrayPokedex[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let addPokedexVC = Storyboards.Pokedex.instantiateViewController(withIdentifier: "addPokedexVC") as! AddPokedexViewController
        addPokedexVC.provenance = .detail
        addPokedexVC.key = arrayPokedex[indexPath.row].key
        addPokedexVC.urlRegion = urlRegion
        self.navigationController?.pushViewController(addPokedexVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItemDelete = UIContextualAction(style: .destructive, title: "Delete") { [self]  (contextualAction, view, boolValue) in
            //Code I want to do here
            deleteRow(with: arrayPokedex[indexPath.row].key, at: indexPath)
        }
        let contextItemEdit = UIContextualAction(style: .normal, title: "Edit") { (contextualAction, view, boolValue) in
            let addPokedexVC = Storyboards.Pokedex.instantiateViewController(withIdentifier: "addPokedexVC") as! AddPokedexViewController
            addPokedexVC.provenance = .editing
            addPokedexVC.key = self.arrayPokedex[indexPath.row].key
            addPokedexVC.urlRegion = self.urlRegion
            self.navigationController?.pushViewController(addPokedexVC, animated: true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItemDelete,contextItemEdit])

        return swipeActions
    }
}
