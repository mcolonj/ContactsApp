//
//  Contacts+CoreDataProperties.swift
//  
//
//  Created by no me on 12/20/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Contacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contacts> {
        return NSFetchRequest<Contacts>(entityName: "Contacts")
    }

    @NSManaged public var importance: Int16
    @NSManaged public var person: Person?
    @NSManaged public var type: ContactType?

}
