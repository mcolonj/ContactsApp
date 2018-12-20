//
//  DataStore.swift
//  Code Test Michael Colon
//
//  Created by no me on 12/17/18.
//  Copyright © 2018 michaelcolon. All rights reserved.
//

import UIKit
import CoreData

typealias success = ()->()
typealias failure = (Error)->()
typealias fetchSuccess = (Any) -> ()
typealias createSuccess = (NSManagedObject)->()

class DataStoreHelper {
    
    static var shared: DataStoreHelper = DataStoreHelper()
    var dataCtx: NSManagedObjectContext?
    
    init() {
        guard let appD = UIApplication.shared.delegate as? AppDelegate else { return }
        dataCtx = appD.persistentContainer.viewContext
    }
    
    func createRecord(_ items: [String: Any], forEntity name: String, success: @escaping createSuccess, failure: @escaping failure) {
        guard let ctx = dataCtx else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: ctx) else { return }
        let object = NSManagedObject(entity: entity, insertInto: dataCtx)
        for item in items {
            object.setValue(item.value, forKeyPath: item.key)
        }
        
        do {
            try ctx.save()
            print("data saved for entity: \(name) with attributes: \(items)")
            success(object)
        } catch let error {
            print("could not save record. \(error) \(error._userInfo)")
            failure(error)
        }
    }
    
    func fetchRecord(predicate:NSPredicate, entityName: String, sortkey: String, ascending: Bool, limit: Int, completion: @escaping fetchSuccess) {
        guard let ctx = dataCtx else { return }
        let objectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if limit > 0 {
            objectFetch.fetchLimit = limit
        }
        objectFetch.predicate = predicate
        if sortkey.isEmpty {
            print("Sort key is empty.")
            return
        }
        objectFetch.sortDescriptors = [NSSortDescriptor.init(key: sortkey, ascending: ascending)]
        do {
            let objects = try ctx.fetch(objectFetch)
            completion(objects)
        } catch let error {
            print("Error occured fetching object \(entityName) with sortKey \(sortkey): \(error) \(error._userInfo)")
        }
    }
    
    func fetchRecord(predicate:NSPredicate, entityName: String, sortkey: String, ascending: Bool, limit: Int) -> [Any] {
        
        var objects: [Any] = [Any]()
        guard let ctx = dataCtx else { return objects }
        
        let objectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        if limit > 0 {
            objectFetch.fetchLimit = limit
        }
        
        objectFetch.predicate = predicate
        
        if sortkey.isEmpty {
            print("Sort key is empty.")
            return objects
        }
        
        objectFetch.sortDescriptors = [NSSortDescriptor.init(key: sortkey, ascending: ascending)]
        
        do {
            
            objects = try ctx.fetch(objectFetch)
            
        } catch let error {
            
            print("Error occured fetching object \(entityName) with sortKey \(sortkey): \(error) \(error._userInfo)")
            
        }
        return objects
    }
    
    static func determinContactValue(importance: Int, owner: Bool) -> Int {
        if owner == true {
            return 10
        }
        return importance
    }
    
    func deleteContact(contact: Contacts, completion: @escaping success) {
    
        guard let ctx:NSManagedObjectContext = DataStoreHelper.shared.dataCtx else { return }
        ctx.delete(contact)
        completion()
    }
    static func addFirstAndLastName(firstName: String, lastName: String, owner: Bool, importance: Int) {
        DataStoreHelper.shared.fetchRecord(predicate: NSPredicate(format: "%@ == true", "person.owner"), entityName: "Contacts", sortkey: "person.lastName", ascending: true, limit: 1) { (object) in
            
            if let contacts: [Contacts] = object as? [Contacts], contacts.count > 0 {
                print("Owner already exists.")
            } else {
                guard let contact: Contacts = DataStoreHelper.shared.createManagedObject(named: "Contacts") as? Contacts else { return }
                guard let person: Person = DataStoreHelper.shared.createManagedObject(named: "Person") as? Person else { return }
                person.firstName = firstName
                person.lastName = lastName
                person.myDevice = owner
                contact.person = person
                DataStoreHelper.shared.saveManagedObjects()
            }
        }
        
    }
    
    static func thisDeviceHasSignedOwner() -> Bool {
        guard let contacts: [Contacts] = DataStoreHelper.shared.fetchRecord(predicate: NSPredicate(format: "%@ != nil", "person"), entityName: "Contacts", sortkey: "importance", ascending: true, limit: 1) as? [Contacts], contacts.count > 0 else {
            
            return false
            
        }
        if let owner: Bool = contacts[0].person?.myDevice, owner == true {
            return true
        }
        return false
    }
    
    static func allContacts(_ completion:@escaping ([Contacts], Bool)->()) {
        DataStoreHelper.shared.fetchRecord(predicate: NSPredicate(value: true), entityName: "Contacts", sortkey: "id", ascending: true, limit: 0) {
            (objects) in
            
            guard let contacts = objects as? [Contacts] else {
                completion([Contacts](), false)
                return
            }
            print("here are your contacts: \(contacts)")
            completion(contacts, true)
        }
            
    }
    
    static func allContacts() -> [Contacts] {
        guard let contacts: [Contacts] = DataStoreHelper.shared.fetchRecord(predicate: NSPredicate(value: true), entityName: "Contacts", sortkey: "importance", ascending: true, limit: 0) as? [Contacts] else { return [Contacts]() }
        return contacts
        
    }
    
    static func allObjects(named: String) -> [NSManagedObject] {
        guard let objects: [NSManagedObject] = DataStoreHelper.shared.fetchRecord(predicate: NSPredicate(value: true), entityName: named, sortkey: "", ascending: true, limit: 0) as? [NSManagedObject] else { return [NSManagedObject]() }
        return objects
    }
    
    static func allPeople(_ completion:@escaping ([Person], Bool)->()) {
        DataStoreHelper.shared.fetchRecord(predicate: NSPredicate(value: true), entityName: "Person", sortkey: "lastName", ascending: true, limit: 0) {
            (objects) in
            
            guard let people = objects as? [Person] else {
                completion([Person](), false)
                return
                
            }
            print("here are the people you know: \(people)")
            completion(people, true)
        }
        
    }
    
    func deleteObjects(_ objects: [NSManagedObject]) {
        guard let ctx = dataCtx else { return }
        for object in objects {
            ctx.delete(object)
        }
    }
    
    func createManagedObject(named name: String) -> NSManagedObject {
        guard let ctx = dataCtx else { return NSManagedObject() }
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: ctx) else { return NSManagedObject()}
        return NSManagedObject(entity: entity, insertInto: dataCtx)
    }
    
    func saveManagedObjects() {
        guard let ctx = dataCtx else { return }
        do {
            try ctx.save()
            print("saved database")
        } catch let error {
            print("could not save record. \(error) \(error._userInfo)")
        }
    }
}
