//
//  Extensions.swift
//  Pokedex
//
//  Created by Jonathan Rodriguez on 19/2/21.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(alertText : String, alertMessage : String) {
        let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Got it", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    func activityStarAnimating() {
        let loader: UIActivityIndicatorView?
        if #available(iOS 13.0, *) {
            loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            loader?.color = .label
        } else {
            // Fallback on earlier versions
            loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            loader?.color = .darkGray
        }
        loader?.center = CGPoint(x: self.frame.size.width  / 2, y: self.frame.size.height / 2 - 44)
        loader?.startAnimating()
        loader?.tag = 475647
        if let loader = loader {
            self.addSubview(loader)
        }
    }

    func activityStarAnimating(with color: UIColor) {
        let loader: UIActivityIndicatorView?
        loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        loader?.color = color
        loader?.center = self.center
        loader?.startAnimating()
        loader?.tag = 475647
        if let loader = loader {
            self.addSubview(loader)
        }
    }

    func activityStopAnimating() {
        if let loader = viewWithTag(475647) {
            loader.removeFromSuperview()
        }
    }
}

import UIKit

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension Sequence {
    public func toDictionary<K: Hashable, V>(_ selector: (Iterator.Element) throws -> (K, V)?) rethrows -> [K: V] {
        var dict = [K: V]()
        for element in self {
            if let (key, value) = try selector(element) {
                dict[key] = value
            }
        }

        return dict
    }
}
