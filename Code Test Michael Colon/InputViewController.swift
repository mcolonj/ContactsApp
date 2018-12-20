//
//  InputViewController.swift
//  Code Test Michael Colon
//
//  Created by no me on 12/18/18.
//  Copyright © 2018 michaelcolon. All rights reserved.
//

import UIKit

class InputViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var street: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var add: UIButton!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    var forUpdating: Bool = false
    var contact: Contacts?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let contact: Contacts = contact, forUpdating == true {
            add.setTitle("Update", for: .normal)
            fillForm(withContact: contact)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeLineAtBotton(field: firstName)
        makeLineAtBotton(field: lastName)
        makeLineAtBotton(field: email)
        makeLineAtBotton(field: phone)
        makeLineAtBotton(field: street)
        makeLineAtBotton(field: city)
        makeLineAtBotton(field: state)
        makeLineAtBotton(field: zip)
        makeLineAtBotton(field: dob)
        add.layer.cornerRadius = add.frame.size.height * 0.1
    }
    
    func fillForm(withContact contact: Contacts) {
        
        if let person = contact.person {
            firstName.text = contact.person?.firstName ?? ""
            lastName.text = contact.person?.lastName ?? ""
            if let birthDate = person.dob {
                dob.text = dateFormatter.string(from: birthDate)
            }
            if let addresses = person.addresses?.allObjects.first as? Addresses{
                street.text = addresses.street1 ?? ""
                city.text = addresses.city ?? ""
                state.text = addresses.state ?? ""
                zip.text = addresses.zip ?? ""
            }
            if let phoneNumbers = person.phoneNumbers?.allObjects.first as? PhoneNumbers {
                phone.text = phoneNumbers.number ?? ""
            }
            if let emails = person.emails?.allObjects.first as? Emails {
                email.text = emails.email ?? ""
            }
        }
        
        
        
        
    }
    func makeLineAtBotton(field: UITextField) {
        
        let border = CALayer()
        let width = CGFloat(0.7)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: field.frame.size.height-width, width:field.frame.size.width, height: field.frame.size.height)
        border.borderWidth = width
        field.layer.addSublayer(border)
        field.layer.masksToBounds = true
        
    }

    func makeOnlyDigitString(string: String) -> String {
        return string.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
    }
    
    @IBAction func dobChanged(_ sender: UITextField) {
        sender.text = dobFieldFormat(string: sender.text ?? "")
    }
    
    func dobFieldFormat(string: String) -> String {
        let digits = makeOnlyDigitString(string: string)
        let format = "**/**/****"
        var formatted = ""
        var index = digits.startIndex
        for character in format {
            if index == digits.endIndex { break }
            if character == "*" {
                formatted.append(digits[index])
                index = digits.index(after: index)
            } else {
                formatted.append(character)
            }
        }
        return formatted
    }
    
    @IBAction func phoneFieldChanged(_ sender: UITextField) {
        sender.text = phoneFieldFormat(string: sender.text ?? "")
    }
    
    func phoneFieldFormat(string: String) -> String {
        let digits = makeOnlyDigitString(string: string)
        let format = "(***) ***-****"
        var formatted = ""
        var index = digits.startIndex
        for character in format {
            if index == digits.endIndex { break }
            if character == "*" {
                formatted.append(digits[index])
                index = digits.index(after: index)
            } else {
                formatted.append(character)
            }
        }
        return formatted
    }
    
    @IBAction func clear(_ sender: Any) {
    
        street.text = ""
        city.text = ""
        state.text = ""
        zip.text = ""
        phone.text = ""
        email.text = ""
        dob.text = ""
    }
    
    func updatePersonDataFromScreen(person: Person) {
        person.firstName = firstName.text
        person.lastName = lastName.text
        if let address = person.addresses?.allObjects.first as? Addresses {
            address.street1 = street.text
            address.city = city.text
            address.state = state.text
            address.zip = zip.text
        } else {
            if let address: Addresses = DataStoreHelper.shared.createManagedObject(named: "Addresses") as? Addresses {
                address.street1 = street.text
                address.city = city.text
                address.state = state.text
                address.zip = zip.text
                address.person = person
            }
        }
        if let phone = person.phoneNumbers?.allObjects.first as? PhoneNumbers {
            phone.number = self.phone.text
        } else {
            if let phone: PhoneNumbers = DataStoreHelper.shared.createManagedObject(named: "PhoneNumbes") as? PhoneNumbers {
                phone.number = self.phone.text
                phone.person = person
            }
        }
        if let emails = person.emails?.allObjects.first as? Emails {
            emails.email = self.email.text
        } else {
            if let emails: Emails = DataStoreHelper.shared.createManagedObject(named: "Emails") as? Emails {
                emails.email = self.email.text
                emails.person = person
            }
        }
        if let dob = dob.text, !dob.isEmpty {
            person.dob = dateFormatter.date(from: dob )
        }
    }
    
    @IBAction func done(_ sender: Any) {
        
        if forUpdating {
            if let contact = contact {
                if let person = contact.person {
                    updatePersonDataFromScreen(person:person)
                    contact.person = person
                    DataStoreHelper.shared.saveManagedObjects()
                    NotificationCenter.default.post(name: Notification.Name("updated.contacts"), object: nil)
                    navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            
            guard let contact: Contacts = DataStoreHelper.shared.createManagedObject(named: "Contacts") as? Contacts else { return }
            guard let person: Person = DataStoreHelper.shared.createManagedObject(named: "Person") as? Person else { return }
            guard let address: Addresses = DataStoreHelper.shared.createManagedObject(named: "Addresses") as? Addresses else { return }
            guard let phone: PhoneNumbers = DataStoreHelper.shared.createManagedObject(named: "PhoneNumbers") as? PhoneNumbers else { return }
            guard let email: Emails = DataStoreHelper.shared.createManagedObject(named: "Emails") as? Emails else { return }
            
            person.firstName = firstName.text
            person.lastName = lastName.text
            address.street1 = street.text
            address.city = city.text
            address.state = state.text
            address.zip = zip.text
            address.person = person
            phone.number = self.phone.text
            email.email = self.email.text
            email.person = person
            if let dob = dob.text, !dob.isEmpty {
                person.dob = dateFormatter.date(from: dob )
            }
            phone.person = person
            contact.person = person
            contact.importance = 8
            print(contact)
            DataStoreHelper.shared.saveManagedObjects()
            NotificationCenter.default.post(name: Notification.Name("updated.contacts"), object: nil)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
