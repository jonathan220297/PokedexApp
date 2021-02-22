//
//  ForgotPasswordViewController.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 19/2/21.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    let authenticationService = AuthenticationService()

    @IBOutlet weak var viewGlass: UIView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var labelErrorEmail: UILabel!
    @IBOutlet weak var buttonSend: LoadingButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.viewGlass.addGestureRecognizer(tapRecognizer)
        self.viewGlass.isUserInteractionEnabled = true
    }

    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }

    // MARK: - Actions
    @IBAction func buttonSendTapped(_ sender: Any) {
        if verifyFormData() {
            buttonSend.showLoading()
            let email = textFieldEmail.text!
            authenticationService.sendPasswordReset(with: email) { [self] (err) in
                buttonSend.hideLoading()
                if let err = err {
                    showAlert(alertText: "Pokedex", alertMessage: err)
                } else {
                    showAlert(alertText: "Pokedex", alertMessage: "Email sent successfully")
                }
            }
        }
    }

    // MARK: - Functions
    fileprivate func verifyFormData() -> Bool {
        resetLabelsErrors()
        let email = textFieldEmail.text!
        if email.isEmpty || !Helpers.isValidEmail(email) {
            if email.isEmpty {
                setErrorLabel(labelErrorEmail, with: "Required")
            }
            if !Helpers.isValidEmail(email) {
                setErrorLabel(labelErrorEmail, with: "Invalid Email")
            }
            return false
        }
        return true
    }

    fileprivate func resetLabelsErrors() {
        labelErrorEmail.isHidden = true
    }

    fileprivate func setErrorLabel(_ sender: UILabel, with message: String) {
        sender.text = message
        sender.isHidden = false
    }
}

extension ForgotPasswordViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizer Delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.viewGlass) {
            return true
        }
        return true
    }
}
