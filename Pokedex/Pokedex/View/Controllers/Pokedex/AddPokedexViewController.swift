//
//  AddPokedexViewController.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 21/2/21.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class AddPokedexViewController: UIViewController {
    let service = PokedexService()

    @IBOutlet weak var imageViewPokedex: UIImageView!
    @IBOutlet weak var textfieldPokedexName: UITextField!
    @IBOutlet weak var labelErrorPokedexName: UILabel!
    @IBOutlet weak var textFieldPokedexType: UITextField!
    @IBOutlet weak var labelErrorPokedexType: UILabel!
    @IBOutlet weak var textViewPokedexDescription: UITextView!
    @IBOutlet weak var labelErrorPokedexDescription: UILabel!
    @IBOutlet weak var tableViewPokemons: UITableView!
    @IBOutlet weak var buttonAdd: LoadingButton!

    var imagePicker: ImagePicker!

    var ref: DatabaseReference!
    var region: Int = 0
    var urlRegion = ""
    var provenance: PokedexAction = .detail
    var key: String = ""

    var pokemonsSelected: [Pokemon] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference(fromURL: "https://pokedex-13e5e-default-rtdb.firebaseio.com/")
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)

        configureViews()
        Helpers.debugOnConsole("Key: \(key)")
    }

    // MARK: - Actions
    @IBAction func buttonAddImageTapped(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }

    @IBAction func buttonAddPokemons(_ sender: Any) {
        let pokemonPickerVC = Storyboards.Pokedex.instantiateViewController(withIdentifier: "pokemonPickerVC") as! PokemonPickerViewController
        pokemonPickerVC.urlRegion = urlRegion
        pokemonPickerVC.modalTransitionStyle = .crossDissolve
        pokemonPickerVC.modalPresentationStyle = .overCurrentContext
        pokemonPickerVC.delegate = self
        self.present(pokemonPickerVC, animated: true)
    }

    @IBAction func buttonAddTapped(_ sender: Any) {
        if verifyFormData() {
            if provenance == .add {
                buttonAdd.showLoading()
                let pokedexName = textfieldPokedexName.text!
                let pokedexType = textFieldPokedexType.text!
                let pokedexDescription = textViewPokedexDescription.text!
                uploadImage { [self] (url) in
                    buttonAdd.hideLoading()
                    var urlImagePokedex = ""
                    if let url = url {
                        urlImagePokedex = url
                    }
                    let pokedex = Pokedex(urlImage: urlImagePokedex, id: UUID().uuidString, name: pokedexName, type: pokedexType, region: region, description: pokedexDescription, userUid: Constants.userID, pokemons: pokemonsSelected)
                    let pokedexRef = ref.child("Pokedex").child(UUID().uuidString)
                    Helpers.debugOnConsole(pokedex.dictionary)
                    pokedexRef.setValue(pokedex.dictionary) { (error, reference) in
                        if let error = error {
                            showAlert(alertText: "Pokedex", alertMessage: error.localizedDescription)
                        } else {
                            navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                buttonAdd.showLoading()
                let pokedexName = textfieldPokedexName.text!
                let pokedexType = textFieldPokedexType.text!
                let pokedexDescription = textViewPokedexDescription.text!
                uploadImage { [self] (url) in
                    buttonAdd.hideLoading()
                    var urlImagePokedex = ""
                    if let url = url {
                        urlImagePokedex = url
                    }
                    let pokedefRef = ref.child("Pokedex").child(key)
                    pokedefRef.updateChildValues(
                        [
                            "urlImage": urlImagePokedex,
                            "name": pokedexName,
                            "type": pokedexType,
                            "description": pokedexDescription
                        ]) { (error, reference) in
                        if let error = error {
                            showAlert(alertText: "Pokedex", alertMessage: error.localizedDescription)
                        } else {
                            navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Functions
    fileprivate func configureViews() {
        switch provenance {
        case .add:
            buttonAdd.setTitle("ADD", for: .normal)
            navigationItem.title = "Add pokedex"
        case .editing:
            buttonAdd.setTitle("UPDATE", for: .normal)
            navigationItem.title = "Update pokedex"
            fetchPokedexInfo()
        case .detail:
            buttonAdd.isHidden = true
            navigationItem.title = "Pokedex"
            textfieldPokedexName.isEnabled = false
            textFieldPokedexType.isEnabled = false
            textViewPokedexDescription.isEditable = false
            fetchPokedexInfo()
        }
    }

    fileprivate func fetchPokedexInfo() {
        let pokedexRef = self.ref.child("Pokedex").child(key)

        pokedexRef.observeSingleEvent(of: .value, with: { snapshot in
            if let pokedex = Pokedex(snapshot: snapshot) {
                self.configurePokedexInfo(with: pokedex)
            }
        })
    }

    fileprivate func configurePokedexInfo(with pokedex: Pokedex) {
        imageViewPokedex.kf.setImage(with: URL(string: pokedex.urlImage))
        textfieldPokedexName.text = pokedex.name
        textFieldPokedexType.text = pokedex.type
        textViewPokedexDescription.text = pokedex.description
        pokemonsSelected = pokedex.pokemons
        tableViewPokemons.reloadData()
    }

    fileprivate func verifyFormData() -> Bool {
        resetLabelsErrors()
        let pokedexName = textfieldPokedexName.text!
        let pokedexType = textFieldPokedexType.text!
        let pokedexDescription = textViewPokedexDescription.text!
        if pokedexName.isEmpty || pokedexType.isEmpty || pokedexDescription.isEmpty {
            if pokedexName.isEmpty {
                setLabelError(labelErrorPokedexName, with: "Required")
            }
            if pokedexType.isEmpty {
                setLabelError(labelErrorPokedexType, with: "Required")
            }
            if pokedexDescription.isEmpty {
                setLabelError(labelErrorPokedexDescription, with: "Required")
            }
            return false
        }
        return true
    }

    fileprivate func resetLabelsErrors() {
        labelErrorPokedexName.isHidden = true
        labelErrorPokedexType.isHidden = true
        labelErrorPokedexDescription.isHidden = true
    }

    fileprivate func setLabelError(_ sender: UILabel, with message: String) {
        sender.text = message
        sender.isHidden = false
    }

    fileprivate func uploadImage(completion: @escaping (_ url: String?) -> Void) {
        var storageRef = StorageReference()
        var imageToUpload = UIImage()
        imageToUpload = self.imageViewPokedex.image!
        storageRef = Storage.storage().reference().child("pokedexImages/\(UUID().uuidString)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        if let uploadData = imageToUpload.jpegData(compressionQuality: 0.20) {
            storageRef.putData(uploadData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    Helpers.debugOnConsole("error: \(String(describing: error?.localizedDescription))")
                    completion(nil)
                } else {
                    storageRef.downloadURL(completion: { (url, error) in
                        guard let downloadURL = url else{
                            Helpers.debugOnConsole("Error: \(String(describing: error?.localizedDescription))")
                            return
                        }
                        completion(downloadURL.absoluteString)
                    })
                }
            }
        }
    }
}

extension AddPokedexViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.imageViewPokedex.image = image
    }
}

extension AddPokedexViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonsSelected.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPokemons", for: indexPath)

        cell.textLabel?.text = pokemonsSelected[indexPath.row].name

        return cell
    }
}

extension AddPokedexViewController: PokemonPickerDelegate {
    func pickPokemons(with array: [Pokemon]) {
        pokemonsSelected = array
        tableViewPokemons.reloadData()
    }
}
