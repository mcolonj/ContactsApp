//
//  ViewController.swift
//  Code Test Michael Colon
//
//  Created by no me on 12/17/18.
//  Copyright © 2018 michaelcolon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!        
    @IBOutlet weak var scrollView: UIScrollView!
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        addTapGestureRecognizer()

    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func addTapGestureRecognizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @IBAction func skipWelcome() {
        self.performSegue(withIdentifier: "showContacts", sender: self)
    }

    @IBAction func addMyName(sender: Any?) {
        
        if DataStoreHelper.thisDeviceHasSignedOwner() == true { return }
        DataStoreHelper.addFirstAndLastName(firstName: self.firstName.text ?? "John", lastName: self.lastName.text ?? "Doe", owner: true, importance: 5)
        self.performSegue(withIdentifier: "showContacts", sender: self)
        
    }
    
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField = nil
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentOffset = CGPoint(x:0,y:0)
        }
        textField.resignFirstResponder()
        return true
    }

    @objc func dismissKeyboard() {
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        view.endEditing(true)
    }
    
    
    @objc func handleKeyboard(notification: Notification) {
        
        if let info = notification.userInfo {
            
            
            guard let screenEnd = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                print("keyboard handle error")
                return
            }
            
            let viewEnd = view.convert(screenEnd, from: view.window)
            
            if let activeField = activeField {
                var point: CGPoint = activeField.frame.origin
                point.y += activeField.frame.size.height + 20
                if(viewEnd.contains(point)) {
                    UIView.animate(withDuration: 0.1) {
                        self.scrollView.contentOffset = CGPoint(x: 0, y: 100)
                    }
                    
                } else {
                    UIView.animate(withDuration: 0.1) {
                        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                    }
                    
                }
            }
        }
        
        
        
    }
    
}

