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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let navigationController = navigationController else { return }
        // Do any additional setup after loading the view, typically from a nib.
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

