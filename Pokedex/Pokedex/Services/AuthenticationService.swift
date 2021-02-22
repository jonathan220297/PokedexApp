//
//  AuthenticationService.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 19/2/21.
//

import Foundation
import FirebaseAuth

class AuthenticationService {
    func createAccount(with email: String, _ password: String, completion: @escaping(_ user: User?, _ error: String?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if let err = err {
                Helpers.debugOnConsole(err.localizedDescription)
                completion(nil, err.localizedDescription)
            } else {
                if let user = result?.user {
                    Helpers.debugOnConsole("Signup Complete. User ID: \(user.uid)")
                    completion(user, nil)
                } else {
                    completion(nil, "Unknown error")
                }
            }
        }
    }

    func loginWithEmail(with email: String, _ password: String, completion: @escaping(_ user: User?, _ error: String?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            if let err = err {
                completion(nil, err.localizedDescription)
            } else {
                if let user = result?.user {
                    completion(user, nil)
                } else {
                    completion(nil, "Unknown error")
                }
            }
        }
    }

    func sendPasswordReset(with email: String, completion: @escaping(_ error: String?) -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if let err = err {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }

    func verifyIsUserLogged() -> Bool {
        if Auth.auth().currentUser != nil {
            if let uid = Auth.auth().currentUser?.uid {
                Constants.userID = uid
                return true
            }
        }
        return false
    }
}
