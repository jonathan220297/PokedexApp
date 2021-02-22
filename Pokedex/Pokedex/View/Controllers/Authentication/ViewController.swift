//
//  ViewController.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 19/2/21.
//

import UIKit

class ViewController: UIViewController {
    let authenticationService = AuthenticationService()

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonLogin: LoadingButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkUserLogged()
    }

    // MARK: - Actions
    @IBAction func buttonLoginTapped(_ sender: Any) {
        let email = textFieldEmail.text!
        let password = textFieldPassword.text!
        login(with: email, password)
    }

    @IBAction func buttonForgotPasswordTapped(_ sender: Any) {
        //forgotPasswordVC
        let forgotPasswordVC = Storyboards.Auth.instantiateViewController(withIdentifier: "forgotPasswordVC") as! ForgotPasswordViewController
        forgotPasswordVC.modalTransitionStyle = .crossDissolve
        forgotPasswordVC.modalPresentationStyle = .overCurrentContext
        present(forgotPasswordVC, animated: true)
    }

    // MARK: - Functions
    fileprivate func checkUserLogged() {
        if authenticationService.verifyIsUserLogged() {
            //move to main page
            let homeVC = Storyboards.Home.instantiateInitialViewController() as! UINavigationController
            homeVC.modalPresentationStyle = .fullScreen
            present(homeVC, animated: true)
        }
    }

    fileprivate func login(with email: String, _ password: String) {
        buttonLogin.showLoading()
        authenticationService.loginWithEmail(with: email, password) { [self] (user, err) in
            buttonLogin.hideLoading()
            if let err = err {
                showAlert(alertText: "Pokedex", alertMessage: err)
            } else {
                if let user = user {
                    Constants.userID = user.uid
                    //move to main page
                    let homeVC = Storyboards.Home.instantiateInitialViewController() as! UINavigationController
                    homeVC.modalPresentationStyle = .fullScreen
                    present(homeVC, animated: true)
                }
            }
        }
    }
}

