//
//  SignupViewController.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 19/2/21.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    var authenticationService = AuthenticationService()

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var labelErrorEmail: UILabel!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var labelErrorPassword: UILabel!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    @IBOutlet weak var labelErrorConfirmPassword: UILabel!
    @IBOutlet weak var buttonCreateAccount: LoadingButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Actions
    @IBAction func buttonCreateTapped(_ sender: Any) {
        if verifyFormData() {
            let email = textFieldEmail.text!
            let password = textFieldPassword.text!
            createAccount(with: email, password)
        }
    }

    @IBAction func buttonLoginTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Functions
    fileprivate func verifyFormData() -> Bool {
        resetLabelErrors()
        let email = textFieldEmail.text!
        let password = textFieldPassword.text!
        let passwordConfirmation = textFieldConfirmPassword.text!
        if email.isEmpty || password.isEmpty || passwordConfirmation.isEmpty || !Helpers.isValidEmail(email) || password != passwordConfirmation {
            if email.isEmpty {
                setLabelError(labelErrorEmail, with: "Required")
            }
            if password.isEmpty {
                setLabelError(labelErrorPassword, with: "Required")
            }
            if passwordConfirmation.isEmpty {
                setLabelError(labelErrorConfirmPassword, with: "Required")
            }
            if !Helpers.isValidEmail(email) {
                setLabelError(labelErrorEmail, with: "Invalid Email")
            }
            if password != passwordConfirmation {
                setLabelError(labelErrorPassword, with: "Passwords does not match")
                setLabelError(labelErrorConfirmPassword, with: "Passwords does not match")
            }
            return false
        }
        return true
    }

    fileprivate func createAccount(with email: String, _ password: String) {
        buttonCreateAccount.showLoading()
        authenticationService.createAccount(with: email, password) { [self] (user, err) in
            buttonCreateAccount.hideLoading()
            if let err = err {
                showAlert(alertText: "Pokedex", alertMessage: err)
            } else {
                if let user = user {
                    Helpers.debugOnConsole("Signup Complete. User ID: \(user.uid)")
                    Constants.userID = user.uid
                    //move to main page
                    let homeVC = Storyboards.Home.instantiateInitialViewController() as! UINavigationController
                    homeVC.modalPresentationStyle = .fullScreen
                    present(homeVC, animated: true)
                }
            }
        }
    }

    fileprivate func resetLabelErrors() {
        labelErrorEmail.isHidden = true
        labelErrorPassword.isHidden = true
        labelErrorConfirmPassword.isHidden = true
    }

    fileprivate func setLabelError(_ sender: UILabel, with message: String) {
        sender.text = message
        sender.isHidden = false
    }
}
