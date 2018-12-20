//
//  ContactsTableViewController.swift
//  Code Test Michael Colon
//
//  Created by no me on 12/18/18.
//  Copyright © 2018 michaelcolon. All rights reserved.
//

import UIKit
import Foundation
import CoreData

struct Section {
    let letter: String
    let contact: Contacts
}

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var callThisPerson: UIButton!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dob: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setName(firstName: String, lastName: String) {
        name.text = firstName + " " + lastName
    }
    func setEmail(emailAddress: String) {
        email.text = emailAddress
    }
    func setPhoneNumber(phone: String) {
        callThisPerson.setTitle(phone, for: .normal)
    }
    func setDob(birthDate: String) {
        dob.text = birthDate
    }
    @IBAction func makeCall(_ sender: UIButton) {
        let phoneNumber: String = sender.currentTitle ?? ""
        if let url = URL(string: "tel://\(phoneNumber)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            print("Couldn't make a call")
        }
    }
    
    @IBAction func viewContactDetails(_ sender: UIButton) {
    
    }
}

class ContactsTableViewController: UIViewController {
    
    @IBOutlet weak var add: UIBarButtonItem!
    
    // Controls
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    let refreshControl: UIRefreshControl = UIRefreshControl()
    let tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    let activityIndicator: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView  = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        view.backgroundColor = .black
        view.alpha = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Data
    var contacts: [Contacts] = {
        return DataStoreHelper.allContacts()
    }()
    
    var groupedContacts: [String: [Contacts]] = [String: [Contacts]]()
    var keys: [String] = [String]()
    
    // Helpers
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    
    // UI
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        contactsUpdated()
        performContactGrouping()
        setupTableView()
        setupSearchController()
        setupActivityIndicator()
        setupPullToReset()
        addObservers()
        navigationController?.view.backgroundColor = .white
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo:view.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo:view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo:view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant:0),
        ])
        tableView.register(UINib(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: "contactcell")
        tableView.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: "sectionheader")
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo:view.topAnchor, constant: 0),
            activityIndicator.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant: 0),
            activityIndicator.leadingAnchor.constraint(equalTo:view.leadingAnchor, constant: 0),
            activityIndicator.trailingAnchor.constraint(equalTo:view.trailingAnchor, constant: 0),
            
        ])
    }
    
    func setupPullToReset() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshContacts(_:)), for: .valueChanged)
        refreshControl.tintColor = .red
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing contacts! Please wait...")
        
    }
    
    @objc func refreshContacts(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        contactsUpdated()
        refreshControl.endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    
    func setupSearchController() {
        
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(contactsUpdated), name: Notification.Name("updated.contacts"), object: nil)
    }
    
    // Contacts
    @objc func contactsUpdated() {
        contacts = DataStoreHelper.allContacts()
        performContactGrouping()
        tableView.reloadData()
    }
    
    func performContactGrouping() {
        groupedContacts = Dictionary(grouping: contacts, by: {String($0.person!.lastName!.prefix(1).uppercased()) })
        keys = groupedContacts.keys.sorted().filter { !$0.isEmpty }
        print(keys)
        if let keys: [String] = keys, let groupedContacts: [String: [Contacts]] = groupedContacts {
            for key in keys {
                print("The key: \(key)")
                let contacts: [Contacts] = groupedContacts[key] ?? [Contacts]()
                for contact in contacts {
                    print(contact.person?.lastName ?? "na")
                }
            }
        }
    }
    
}

extension ContactsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContacts(_ searchText: String) {
        let filtered: [Contacts] = contacts.filter { contact in
            
            if let person: Person = contact.person, let firstName = person.firstName, let lastName = person.lastName {
                if firstName.lowercased().contains(searchText.lowercased()) || lastName.lowercased().contains(searchText.lowercased()) {
                    return true
                }
            }
            return false
            
        }
        groupedContacts = Dictionary(grouping: filtered, by: {String($0.person!.lastName!.prefix(1).uppercased()) })
        keys = groupedContacts.keys.sorted().filter { !$0.isEmpty }
        print(keys)
        if let keys: [String] = keys, let groupedContacts: [String: [Contacts]] = groupedContacts {
            for key in keys {
                print("The key: \(key)")
                let contacts: [Contacts] = groupedContacts[key] ?? [Contacts]()
                for contact in contacts {
                    print(contact.person?.lastName ?? "na")
                }
            }
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchBarIsEmpty() {
            contactsUpdated()
        }
        filterContacts(searchController.searchBar.text ?? "")
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, text.isEmpty {
            contactsUpdated()
        } else {
            filterContacts(searchBar.text ?? "")
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        contactsUpdated()
    }
    
}

extension ContactsTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let contactsForSection: [Contacts] = groupedContacts[String(keys[section])], contactsForSection.count > 0 else { return 1 }
        print("Contacts count: \(contactsForSection.count)")
        return contactsForSection.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactcell", for: indexPath) as! ContactCell
        
        guard let contactsForSection: [Contacts] = groupedContacts[keys[indexPath.section]], contactsForSection.count > 0 else {
            return cell
        }


        if let contact: Contacts = contactsForSection[indexPath.row] {
            cell.setName(firstName: contact.person?.firstName ?? "", lastName: contact.person?.lastName ?? "")
            cell.setEmail(emailAddress: (contact.person?.emails?.allObjects.first as? Emails)?.email ?? "")
            cell.setPhoneNumber(phone: (contact.person?.phoneNumbers?.allObjects.first as? PhoneNumbers)?.number ?? "")
            if let dob = contact.person?.dob {
                cell.setDob(birthDate:dateFormatter.string(from: dob))
            } else {
                cell.setDob(birthDate: "")
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionheader") as! SectionHeader
        view.titleLabel.text = String(keys[section])
        return view as UIView
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contactsForSection: [Contacts] = groupedContacts[keys[indexPath.section]], contactsForSection.count > 0 else { return }
        guard let contact: Contacts = contactsForSection[indexPath.row] else { return }
        guard let editScreen: InputViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "contactDetails") as? InputViewController else { return }
        editScreen.forUpdating = true
        editScreen.contact = contact
        if let navigationController = navigationController {
            navigationController.pushViewController(editScreen, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let contactsForSection: [Contacts] = groupedContacts[keys[indexPath.section]], contactsForSection.count > 0 else { return }
            guard let contact: Contacts = contactsForSection[indexPath.row] else { return }
            DataStoreHelper.shared.deleteContact(contact: contact, completion: {
                NotificationCenter.default.post(name: Notification.Name("updated.contacts"), object: nil)
                DataStoreHelper.shared.saveManagedObjects()
            })
        }
    }
}

